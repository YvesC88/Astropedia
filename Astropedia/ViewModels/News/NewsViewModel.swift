//
//  NewsViewModel.swift
//  Astropedia
//
//  Created by Yves Charpentier on 16/09/2023.
//

import Foundation
import Combine
import UserNotifications
import BackgroundTasks

final class NewsViewModel {

    // Deja vu plusieurs fois..
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    private let articleService = ArticleService(wrapper: FirebaseWrapper())
    private let pictureService = PictureService(wrapper: FirebaseWrapper())
    
    @Published var article: [Article] = []
    @Published var picture: [APIApod] = []
    @Published var isLoading: Bool?
    
    init() {
        Task {
            await fetchPictures()
        }
        fetchArticles()
    }
    
    // J'ai deja vu cette methode qq part.. Evite autant que possible de dupliquer le code.
    // Tu peux creer une class AppDateFormatter qui est utiliser par tes viewModels. Tu ecris le code une fois
    private func formatDate(date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    private func fetchArticles() {
        articleService.fetchArticle(collectionID: "article") { article, error in
            for data in article {
                self.article.append(data)
            }
        }
    }
    
    private func fetchPictures() async -> Result<[APIApod], Error> {
        isLoading = true
        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let endDate = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        do {
            let pictures = try await pictureService.getPicture(startDate: formatDate(date: startDate), endDate: formatDate(date: endDate))
            self.picture = pictures
            self.isLoading = false
            return .success(pictures)
        } catch { return .failure(error) }
    }
    
    func scheduleDailyNotification() {
        let lastPicture = self.picture.last?.toPicture()
        let content = UNMutableNotificationContent()
        content.title = "Nouvelle image disponible !"
        content.subtitle = lastPicture?.title ?? ""
        content.body = lastPicture?.explanation ?? ""
        let dateComponents = DateComponents(hour: 12, minute: 00)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: "dailyNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Erreur lors de la planification de la notification : \(error.localizedDescription)")
            } else {
                print("Notification planifiée avec succès pour 12 heures chaque jour.")
            }
        }
    }
    
    func isFavoriteArticle(article: Article) -> Bool {
        return articleService.isFavoriteArticle(article: article)
    }
    
    func unsaveArticle(article: Article) {
        articleService.unsaveArticle(article: article)
    }
    
    func saveArticle(article: Article) {
        articleService.saveArticle(title: article.title, subtitle: article.subtitle, image: article.image, source: article.source, articleText: article.articleText, id: article.id)
    }
}

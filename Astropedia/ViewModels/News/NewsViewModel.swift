//
//  NewsViewModel.swift
//  Astropedia
//
//  Created by Yves Charpentier on 16/09/2023.
//

import Foundation
import Combine
import UserNotifications

class NewsViewModel: NSObject {
    
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
    
    override init() {
        super.init()
        fetchPictures()
        fetchArticles()
        scheduleDailyNotification()
    }
    
    private final func formatDate(date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    private final func fetchArticles() {
        articleService.fetchArticle(collectionID: "article") { article, error in
            for data in article {
                self.article.append(data)
            }
        }
    }
    
    final func fetchPictures() {
        isLoading = true
        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let endDate = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        pictureService.getPicture(startDate: formatDate(date: startDate), endDate: formatDate(date: endDate)) { picture in
            if let picture = picture {
                self.picture = picture
            }
            self.isLoading = false
        }
    }
    
    func scheduleDailyNotification() {
        DispatchQueue.main.async {
            let content = UNMutableNotificationContent()
            content.title = "Nouvelle image disponible !"
            content.body = "\(self.picture.last?.toPicture().explanation ?? "")"
            let dateComponents = DateComponents(hour: 11, minute: 23)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            let request = UNNotificationRequest(identifier: "dailyNotification", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { (error) in
                if let error = error {
                    print("Erreur lors de la planification de la notification : \(error.localizedDescription)")
                } else {
                    print("Notification planifiée avec succès pour 9 heures du matin chaque jour.")
                }
            }
        }
    }
    
    final func isFavoriteArticle(article: Article) -> Bool {
        return articleService.isFavoriteArticle(article: article)
    }
    
    final func unsaveArticle(article: Article) {
        articleService.unsaveArticle(article: article)
    }
    
    final func saveArticle(article: Article) {
        articleService.saveArticle(title: article.title, subtitle: article.subtitle, image: article.image, source: article.source, articleText: article.articleText, id: article.id)
    }
}

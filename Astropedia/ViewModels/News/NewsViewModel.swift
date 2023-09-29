//
//  NewsViewModel.swift
//  Astropedia
//
//  Created by Yves Charpentier on 16/09/2023.
//

import Foundation
import Combine

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
    
    private final func fetchPictures() {
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

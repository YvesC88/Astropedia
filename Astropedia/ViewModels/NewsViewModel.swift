//
//  NewsViewModel.swift
//  Astropedia
//
//  Created by Yves Charpentier on 16/09/2023.
//

import Foundation
import Combine

class NewsViewModel: NSObject {
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    let articleService = ArticleService(wrapper: FirebaseWrapper())
    let pictureService = PictureService(wrapper: FirebaseWrapper())
    
    @Published var article: [Article] = []
    @Published var picture: [APIApod] = []
    @Published var isLoading: Bool?
    
    override init() {
        super.init()
        fetchPictures()
        fetchArticles()
    }
    
    func formatDate(date: Date) -> String {
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
}

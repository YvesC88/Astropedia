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
    
    var articleService = ArticleService(wrapper: FirebaseWrapper())
    var pictureService = PictureService(wrapper: FirebaseWrapper())
    
    @Published var article: [Article] = []
    @Published var picture: [APIApod] = []
    
    override init() {
        super.init()
        loadPicture()
        loadArticle()
    }
    
    func formatDate(date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    final func loadArticle() {
        articleService.fetchArticle(collectionID: "article") { article, error in
            for data in article {
                self.article.append(data)
            }
        }
    }
    
    final func loadPicture() {
        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let endDate = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        pictureService.getPicture(startDate: formatDate(date: startDate), endDate: formatDate(date: endDate)) { picture in
            if let picture = picture {
                self.picture = picture
            }
        }
    }
}

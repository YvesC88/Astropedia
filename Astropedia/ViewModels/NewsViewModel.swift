//
//  NewsViewModel.swift
//  Astropedia
//
//  Created by Yves Charpentier on 16/09/2023.
//

import Foundation
import Combine

class NewsViewModel: NSObject {
    
    private var cancellables: Set<AnyCancellable> = []
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    func testFormatter(date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    
    var articleService = ArticleService(wrapper: FirebaseWrapper())
    var pictureService = PictureService(wrapper: FirebaseWrapper())
    
    @Published var article: [Article] = []
    @Published var picture: [APIApod] = []
    
    override init() {
        super.init()
        loadPicture()
        loadArticle()
    }
    
    func loadArticle() {
        articleService.fetchArticle(collectionID: "article") { article, error in
            for data in article {
                self.article.append(data)
            }
        }
    }
    
    func loadPicture() {
        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())
        let endDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        
        let startDateString = testFormatter(date: startDate!)
        let endDateString = testFormatter(date: endDate!)
        
        pictureService.getPicture(startDate: startDateString, endDate: endDateString) { picture in
            if let picture = picture {
                self.picture = picture
            }
        }
    }
}

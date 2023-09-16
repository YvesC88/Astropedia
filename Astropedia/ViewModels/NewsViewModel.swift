//
//  NewsViewModel.swift
//  Astropedia
//
//  Created by Yves Charpentier on 16/09/2023.
//

import Foundation

protocol ArticleDelegate {
    func reloadArticleTableView()
}

protocol PictureDelegate {
    func reloadPictureTableView()
    func showErrorLoading(text: String, isHidden: Bool)
    func startAnimating()
    func stopAnimating()
}

class NewsViewModel {
    
    // MARK: - Article
    
    var articleDelegate: ArticleDelegate?
    var articleService = ArticleService(wrapper: FirebaseWrapper())
    
    var article: [Article] = [] {
        didSet {
            articleDelegate?.reloadArticleTableView()
        }
    }
    
    final func loadArticle() {
        articleService.fetchArticle(collectionID: "article") { article, error in
            for data in article {
                self.article.append(data)
            }
        }
    }
    
    // MARK: - Piture
    
    var pictureDelegate: PictureDelegate?
    var pictureService = PictureService(wrapper: FirebaseWrapper())
    var picture: [APIApod] = [] {
        didSet {
            pictureDelegate?.reloadPictureTableView()
        }
    }
    
    
    final func loadPicture() {
        pictureDelegate?.showErrorLoading(text: "", isHidden: true)
        pictureDelegate?.startAnimating()
        let date = Date()
        let dateFormat = "yyyy-MM-dd"
        let calendar = Calendar.current
        let start = calendar.date(byAdding: .day, value: -1, to: date)
        let startDate = getFormattedDate(date: start ?? Date(), dateFormat: dateFormat)
        let newDate = calendar.date(byAdding: .day, value: -7, to: date)
        let endDate = getFormattedDate(date: newDate ?? Date(), dateFormat: dateFormat)
        pictureService.getPicture(startDate: endDate, endDate: startDate) { picture in
            if let picture = picture {
                self.picture = picture
            } else {
                self.pictureDelegate?.showErrorLoading(text: "Erreur serveur", isHidden: false)
            }
            self.pictureDelegate?.stopAnimating()
        }
    }
}

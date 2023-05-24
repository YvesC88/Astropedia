//
//  FirebaseArticle.swift
//  Planets
//
//  Created by Yves Charpentier on 09/05/2023.
//

import UIKit

struct FirebaseArticle: Codable {
    
    let title: String
    let image: String
    let source: String
    let subTitle: String
    let articleText: [String]
    let id: String
}

extension FirebaseArticle {
    
    func toArticle(completion: @escaping (Article?) -> Void) {
        var article = Article(title: self.title,
                              subtitle: self.subTitle,
                              image: nil,
                              articleText: self.articleText,
                              source: self.source,
                              id: self.id)
        
        if let imageURL = URL(string: self.image) {
            URLSession.shared.dataTask(with: imageURL) { data, response, error in
                guard let data = data, error == nil else {
                    completion(nil)
                    return
                }
                article.image = data
                completion(article)
            }
            .resume()
        } else {
            completion(nil)
        }
    }
}

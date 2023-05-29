//
//  FirebaseArticle.swift
//  Planets
//
//  Created by Yves Charpentier on 09/05/2023.
//

import UIKit

struct FirebaseArticle: Codable {
    
    let title, image, source, subTitle, id: String
    let articleText: [String]
}

extension FirebaseArticle {
    
    func toArticle() -> Article {
        return Article(title: self.title, subtitle: self.subTitle, image: self.image, articleText: self.articleText, source: self.source, id: self.id)
    }
}

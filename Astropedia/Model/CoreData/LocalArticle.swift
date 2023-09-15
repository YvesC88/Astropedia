//
//  LocalArticle.swift
//  Planets
//
//  Created by Yves Charpentier on 16/05/2023.
//

import Foundation
import CoreData

class LocalArticle: NSManagedObject { }

extension LocalArticle {
    
    // MARK: - Properties
    
    func toArticle() -> Article {
        return Article(title: title,
                       image: image,
                       source: source,
                       subtitle: subtitle,
                       id: id,
                       articleText: articleText)
    }
    
}

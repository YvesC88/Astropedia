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
        return Article(title: title, subtitle: subtitle, image: image, articleText: articleText, source: source, id: id)
    }
    
}

//
//  ArticleService.swift
//  Planets
//
//  Created by Yves Charpentier on 16/05/2023.
//

import UIKit
import CoreData

class ArticleService {

    func saveArticle(title: String?, subtitle: String?, image: String?, source: String?, articleText: [String]?, id: String?)
    {
        let coreDataStack = CoreDataStack()
        let context = coreDataStack.persistentContainer.viewContext
        let articles = LocalArticle(context: context)
        articles.title = title
        articles.subtitle = subtitle
        articles.image = image
        articles.source = source
        articles.articleText = articleText
        articles.id = id
        do {
            try context.save()
        } catch {
            print("Erreor \(error)")
        }
    }
    
    func unsaveArticle(article: Article) {
        do {
            try CoreDataStack.share.unsaveArticle(article: article)
        } catch {
            print("Error : \(error)")
        }
    }
    
    func isFavoriteArticle(article: Article) -> Bool {
        let context = CoreDataStack.share.viewContext
        let fetchRequest: NSFetchRequest<LocalArticle> = LocalArticle.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", article.id ?? "")
        return ((try? context.count(for: fetchRequest)) ?? 0) > 0
    }
    
}

//
//  ArticleService.swift
//  Astropedia
//
//  Created by Yves Charpentier on 16/05/2023.
//

import UIKit
import CoreData

class ArticleService {
    
    // MARK: - Properties
    let firebaseWrapper: FirebaseProtocol
    private let coreDataStack = CoreDataStack()
    
    init(wrapper: FirebaseProtocol) {
        self.firebaseWrapper = wrapper
    }
    
    // MARK: - Methods
    func fetchArticle(collectionID: String, completion: @escaping ([Article], String?) -> ()) {
        firebaseWrapper.fetchArticle(collectionID: collectionID) { article, error in
            if let article = article {
                completion(article, nil)
            } else {
                completion([], error)
            }
        }
    }
    
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
            print("Error \(error)")
        }
    }
    
    func unsaveArticle(article: Article) {
        do {
            try coreDataStack.unsaveArticle(article: article)
        } catch {
            print("Error : \(error)")
        }
    }
    
    func isFavoriteArticle(article: Article) -> Bool {
        let context = coreDataStack.viewContext
        let fetchRequest: NSFetchRequest<LocalArticle> = LocalArticle.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", article.id ?? "")
        return ((try? context.count(for: fetchRequest)) ?? 0) > 0
    }
}

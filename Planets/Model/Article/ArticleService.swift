//
//  ArticleService.swift
//  Planets
//
//  Created by Yves Charpentier on 16/05/2023.
//

import UIKit
import CoreData

protocol ArticleDelegate {
    func reloadArticleTableView()
}

class ArticleService {
    
    // MARK: - Properties
    let firebaseWrapper: FirebaseProtocol
    var articleDelegate: ArticleDelegate?
    
    var article: [Article] = [] {
        didSet {
            articleDelegate?.reloadArticleTableView()
        }
    }
    
    init(wrapper: FirebaseProtocol) {
        self.firebaseWrapper = wrapper
    }
    
    // MARK: - Methods
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
    
    func fetchArticle(collectionID: String, completion: @escaping ([Article], String?) -> ()) {
        firebaseWrapper.fetchArticle(collectionID: collectionID) { article, error in
            if let article = article {
                completion(article, nil)
            } else {
                completion([], error)
            }
        }
    }
    
    final func loadArticle() {
        fetchArticle(collectionID: "article") { article, error in
            for data in article {
                self.article.append(data)
            }
        }
    }
}

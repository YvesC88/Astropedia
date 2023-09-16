//
//  FavoriteService.swift
//  Astropedia
//
//  Created by Yves Charpentier on 09/07/2023.
//

import Foundation
import CoreData

protocol FavoriteDelegate {
    func reloadTableView()
    func showEmptyLabel(isHidden: Bool)
}

enum CategoryType {
    case picture, article
}

struct FavoriteCategory {
    var name: String
    var type: CategoryType
    var data: [Any]
}

class FavoriteService {
    
    var favoriteDelegate: FavoriteDelegate?
    
    var favoritePicture: [LocalPicture] = [] {
        didSet {
            favoriteDelegate?.reloadTableView()
        }
    }
    
    var favoriteArticle: [LocalArticle] = [] {
        didSet {
            favoriteDelegate?.reloadTableView()
        }
    }
    
    var favorites: [FavoriteCategory] = [] {
        didSet {
            favoriteDelegate?.reloadTableView()
        }
    }
    
    var filteredFavorites: [FavoriteCategory] = [] {
        didSet {
            favoriteDelegate?.reloadTableView()
        }
    }
    
    func fetchFavoriteData() {
        let pictureRequest: NSFetchRequest<LocalPicture> = LocalPicture.fetchRequest()
        let articleRequest: NSFetchRequest<LocalArticle> = LocalArticle.fetchRequest()
        guard let picture = try? CoreDataStack.share.viewContext.fetch(pictureRequest) else { return }
        favoritePicture = picture
        guard let article = try? CoreDataStack.share.viewContext.fetch(articleRequest) else { return }
        favoriteArticle = article
        favorites = [
            FavoriteCategory(name: "Mes images", type: .picture, data: favoritePicture),
            FavoriteCategory(name: "Mes articles", type: .article, data: favoriteArticle)
            ]
        filteredFavorites = favorites
    }
    
    func showIsEmpty() {
        favoriteDelegate?.showEmptyLabel(isHidden: favoriteArticle.isEmpty && favoritePicture.isEmpty)
    }
}

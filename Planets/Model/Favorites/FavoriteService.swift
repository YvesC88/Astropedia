//
//  FavoriteService.swift
//  Planets
//
//  Created by Yves Charpentier on 09/07/2023.
//

import Foundation
import CoreData

protocol FavoriteDelegate {
    func reloadTableView()
    func showEmptyLabel(isHidden: Bool)
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
    
    var favorites: [(category: String, data: [Any])] = [] {
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
            (category: "Mes images", data: favoritePicture),
            (category: "Mes articles", data: favoriteArticle)]
    }
    
    func showIsEmpty() {
        favoriteDelegate?.showEmptyLabel(isHidden: favoriteArticle.isEmpty && favoritePicture.isEmpty)
    }
}

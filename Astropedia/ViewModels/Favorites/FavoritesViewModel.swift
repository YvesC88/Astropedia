//
//  FavoritesViewModel.swift
//  Astropedia
//
//  Created by Yves Charpentier on 24/09/2023.
//

import Foundation
import CoreData

class FavoritesViewModel: NSObject {
    
    private let coreDataStack = CoreDataStack()
    
    @Published var favorites: [Favorite] = []
    @Published var filteredFavorites: [Favorite] = []
    @Published var isEmptyFavorite: Bool?
    
    override init() {
        super.init()
        fetchFavorite()
        isEmpty()
    }
    
    final func fetchFavorite() {
        let pictureRequest: NSFetchRequest<LocalPicture> = LocalPicture.fetchRequest()
        let articleRequest: NSFetchRequest<LocalArticle> = LocalArticle.fetchRequest()
        guard let picture = try? coreDataStack.viewContext.fetch(pictureRequest) else { return }
        guard let article = try? coreDataStack.viewContext.fetch(articleRequest) else { return }
        favorites = [
            Favorite(name: "Mes images", type: .picture, data: picture),
            Favorite(name: "Mes articles", type: .article, data: article)
        ]
        filteredFavorites = favorites
    }
    
    final func isEmpty() {
        isEmptyFavorite = favorites.allSatisfy { $0.data.isEmpty }
    }
}

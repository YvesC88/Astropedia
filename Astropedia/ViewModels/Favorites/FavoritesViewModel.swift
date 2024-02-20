//
//  FavoritesViewModel.swift
//  Astropedia
//
//  Created by Yves Charpentier on 24/09/2023.
//

import Foundation
import CoreData

final class FavoritesViewModel {
    
    private let coreDataStack = CoreDataStack()
    
    @Published private(set) var favorites: [Favorite] = []
    @Published private(set) var filteredFavorites: [Favorite] = []
    @Published private(set) var isEmptyFavorite: Bool?

    init() {
        fetchFavorite()
        isEmpty()
    }
    
    func fetchFavorite() {
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
    
    func isEmpty() {
        isEmptyFavorite = favorites.allSatisfy { $0.data.isEmpty }
    }
}

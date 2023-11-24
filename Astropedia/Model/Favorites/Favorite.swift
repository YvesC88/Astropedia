//
//  FavoriteService.swift
//  Astropedia
//
//  Created by Yves Charpentier on 09/07/2023.
//

import Foundation
import CoreData

enum CategoryType {
    case picture, article
}

struct Favorite {
    var name: String
    var type: CategoryType
    var data: [Any]
}

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
    // Pourquoi des var et non pas des let ?
    var name: String
    var type: CategoryType
    // Le type Any est a evite si c'est possible. Le soucis c'est qu'on peut tout y mettre dedans. Tout et n'importe quoi..
    var data: [Any]
}

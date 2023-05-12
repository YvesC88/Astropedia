//
//  FirebaseArticle.swift
//  Planets
//
//  Created by Yves Charpentier on 09/05/2023.
//

import UIKit

struct FirebaseArticle: Codable {
    
    let title: String
    let image: String
    let source: String
    let subTitle: String
    let articleText: [String]
}

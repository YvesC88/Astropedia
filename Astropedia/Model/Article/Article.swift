//
//  FirebaseArticle.swift
//  Astropedia
//
//  Created by Yves Charpentier on 09/05/2023.
//

import UIKit

struct Article: Codable {
    
    let title, image, source, subtitle, id: String?
    let articleText: [String]?
}

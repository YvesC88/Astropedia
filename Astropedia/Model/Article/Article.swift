//
//  FirebaseArticle.swift
//  Astropedia
//
//  Created by Yves Charpentier on 09/05/2023.
//

import UIKit

struct Article: Codable {
    // Pour aider a la lecture on evite de delarer de cette facon. Tu le verras presque jamais surtout pour la definition de model ou on a besoin que ce soit clair
    // Ici on n'a pas besoin de gagner des lignes
    // Pourquoi tout est en optionel ? Tu peux avoir des articles sans title ? ou sans id ? Pas sur ;)
    let title, image, source, subtitle, id: String?
    let articleText: [String]?
}

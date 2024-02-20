//
//  FirebaseQuestion.swift
//  Astropedia
//
//  Created by Yves Charpentier on 18/06/2023.
//

import Foundation

enum GameState {
    // Idem ici pour l'indentation on essaie de mettre 1 sur chaque ligne. Privilegier la comprehension au gain de ligne de code.
    case notStarted
    case inProgress
    case ended
}

struct Question: Codable {
    
    let text: String
    let answer: Bool
}

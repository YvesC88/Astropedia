//
//  FirebaseQuestion.swift
//  Astropedia
//
//  Created by Yves Charpentier on 18/06/2023.
//

import Foundation

enum GameState {
    case notStarted, inProgress, ended
}

struct Question: Codable {
    
    let text: String
    let answer: Bool
}

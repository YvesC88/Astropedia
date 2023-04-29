//
//  Planet.swift
//  Planets
//
//  Created by Yves Charpentier on 16/01/2023.
//

import UIKit

struct FirebaseData: Codable {
    // MARK: - Properties
    
    let name: String
    let image: String
    let tempMoy: String
    let gravity: Double
    let statistics: [String]
    let source: String
    let membership: String
    let type: String
    let diameter: Double
}

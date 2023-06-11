//
//  Planet.swift
//  Planets
//
//  Created by Yves Charpentier on 16/01/2023.
//

import Foundation

struct FirebaseData: Codable {
    // MARK: - Properties
    
    let name, image, tempMoy, source, membership, type: String
    let sat: Int
    let gravity, diameter: Double
    let statistics, galleries: [String]
}

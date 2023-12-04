//
//  Planet.swift
//  Astropedia
//
//  Created by Yves Charpentier on 16/01/2023.
//

import Foundation

struct SolarSystem: Equatable {
    // MARK: - Properties
    
    let name, image, tempMoy, source, membership, type: String
    let sat: Int
    let gravity, diameter: Double
    let statistics, galleries: [String]
}

struct SolarSystemCategory {
    var name: String
    var data: [SolarSystem]
}

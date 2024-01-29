//
//  Planet.swift
//  Astropedia
//
//  Created by Yves Charpentier on 16/01/2023.
//

import Foundation
import UIKit

enum CelestialObject {
    
    static let celestObjects = [
        "Soleil": UIImage(named: "Soleil"),
        "Sirius": UIImage(named: "Sirius"),
        "Mercure": UIImage(named: "Mercure"),
        "Mars": UIImage(named: "Mars"),
        "Jupiter": UIImage(named: "Jupiter"),
        "Saturne": UIImage(named: "Saturne"),
        "Uranus": UIImage(named: "Uranus"),
        "Neptune": UIImage(named: "Neptune"),
        "Vénus": UIImage(named: "Vénus"),
        "Terre": UIImage(named: "Terre"),
        "Éris": UIImage(named: "Éris"),
        "Hauméa": UIImage(named: "Hauméa"),
        "Makémaké": UIImage(named: "Makémaké"),
        "Pluton": UIImage(named: "Pluton"),
        "Cérès": UIImage(named: "Cérès"),
        "Lune": UIImage(named: "Lune"),
        "Phobos": UIImage(named: "Phobos"),
        "Déimos": UIImage(named: "Déimos"),
        "Io": UIImage(named: "Io"),
        "Europe": UIImage(named: "Europe"),
        "Callisto": UIImage(named: "Callisto"),
        "Ganymède": UIImage(named: "Ganymède"),
        "Titan": UIImage(named: "Titan"),
        "Japet": UIImage(named: "Japet"),
        "Rhéa": UIImage(named: "Rhéa"),
        "Téthys": UIImage(named: "Téthys"),
        "Dioné": UIImage(named: "Dioné"),
        "Encelade": UIImage(named: "Encelade"),
        "Mimas": UIImage(named: "Mimas"),
        "Hypérion": UIImage(named: "Hypérion")
    ]
}

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

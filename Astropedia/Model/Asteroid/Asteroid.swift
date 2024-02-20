//
//  Asteroid.swift
//  Astropedia
//
//  Created by Yves Charpentier on 03/04/2023.
//

import Foundation

// Ce model lui n'est pas Codable comme les autres ? Il n'est pas sauvegarde ni fetche ?
struct Asteroid {
    
    // MARK: - Properties
    
    // Pourquoi tout est en var et optionel ?
    // L'optionel a une signification tres importante celle de l'absence de valeur. Ici name en optionel signifie qu'on pourrait creer un asteriod sans name.
    // est-ce que selon toi c'est qq chose de possible ? Si oui alors on trouche a rien sinon, on le passe en non optionel
    var name: String?
    var estimatedDiameter: Double?
    var isPotentiallyHazardous: String?
    var url: URL?
    var relativeVelocity: Double?
    var missDistance: Double?
    var closeApproachDate: String?
    var absoluteMagnitude: Double?
}

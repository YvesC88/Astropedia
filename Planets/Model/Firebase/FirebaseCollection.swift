//
//  FirebaseCollection.swift
//  Planets
//
//  Created by Yves Charpentier on 27/06/2023.
//

import Foundation

struct FirebaseCollection {
    
    let categories = ["Étoile", "Planètes", "Planètes naines", "Lunes"]
    var solarSystem: [(category: String, data: [FirebaseData])] = []
    
    // MARK: - Properties Collections
    var celestialObjects: [FirebaseData] = []
    var planets: [FirebaseData] = []
    var moons: [FirebaseData] = []
    var stars: [FirebaseData] = []
    var dwarfPlanets: [FirebaseData] = []
    
    // MARK: - Properties filtered Collections
    var filteredPlanets: [FirebaseData] = []
    var filteredMoons: [FirebaseData] = []
    var filteredStars: [FirebaseData] = []
    var filteredDwarfPlanets: [FirebaseData] = []
    
}

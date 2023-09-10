//
//  FirebaseCollection.swift
//  Planets
//
//  Created by Yves Charpentier on 27/06/2023.
//

import Foundation

struct SolarSystemCollection {
    
    let categories = ["Étoile", "Planètes", "Planètes naines", "Lunes"]
    var solarSystem: [SolarSystemCategory] = []
    
    // MARK: - Properties Collections
    var planets: [SolarSystem] = []
    var moons: [SolarSystem] = []
    var stars: [SolarSystem] = []
    var dwarfPlanets: [SolarSystem] = []
    
    // MARK: - Properties filtered Collections
    var filteredPlanets: [SolarSystem] = []
    var filteredMoons: [SolarSystem] = []
    var filteredStars: [SolarSystem] = []
    var filteredDwarfPlanets: [SolarSystem] = []
    
    var updateStars: [SolarSystem] { return isFiltering ? filteredStars : stars }
    var updatePlanets: [SolarSystem] { return isFiltering ? filteredPlanets : planets }
    var updateDwarfPlanets: [SolarSystem] { return isFiltering ? filteredStars : dwarfPlanets }
    var updateMoons: [SolarSystem] { return isFiltering ? filteredMoons : moons }
    
    var searchText: String {
        return SolarSystemViewController.searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() ?? ""
    }
    
    var isFiltering: Bool { return searchText.isEmpty }
}

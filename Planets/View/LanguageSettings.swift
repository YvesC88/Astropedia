//
//  AppSettings.swift
//  Planets
//
//  Created by Yves Charpentier on 31/05/2023.
//

import Foundation

struct LanguageSettings {
    static var currentLanguage = Bundle.main.preferredLocalizations.first
    static let placeholderFr = "Rechercher dans le Système Solaire"
    static let placeholderEn = "Search in Solar System"
    
    static let categoriesFr = ["Étoile", "Planètes", "Planètes naines", "Lunes"]
    static let categoriesEn = ["Star", "Planets", "Dwarf planets", "Moons"]
    static var categories: [String] {
        return (currentLanguage == "fr") ? categoriesFr : categoriesEn
    }
    
    static var planets: [FirebaseData] = []
    static var moons: [FirebaseData] = []
    static var stars: [FirebaseData] = []
    static var dwarfPlanets: [FirebaseData] = []
    
    static var filteredPlanets: [FirebaseData] = []
    static var filteredMoons: [FirebaseData] = []
    static var filteredStars: [FirebaseData] = []
    static var filteredDwarfPlanets: [FirebaseData] = []
    
    static var collectionStar: String {
        return (currentLanguage == "fr") ? "stars" : "starsEn"
    }
    static var collectionPlanet: String {
        return (currentLanguage == "fr") ? "planets" : "planetsEn"
    }
    static var collectionDwarfPlanet: String {
        return (currentLanguage == "fr") ? "dwarfPlanets" : "dwarfPlanets"
    }
    static var collectionMoon: String {
        return (currentLanguage == "fr") ? "moons" : "moonsEn"
    }
}

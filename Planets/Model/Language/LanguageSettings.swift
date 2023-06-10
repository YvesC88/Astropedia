//
//  AppSettings.swift
//  Planets
//
//  Created by Yves Charpentier on 31/05/2023.
//

import Foundation

struct LanguageSettings {
    let language: LanguageProtocol
    
    init(language: LanguageProtocol) {
        self.language = language
    }
    var currentLanguage: String {
        return language.getCurrentLanguage()
    }
    
    var categories: [String] {
        return currentLanguage == "fr" ? SolarSystemViewController.categoriesFr : SolarSystemViewController.categoriesEn
    }
    var planets: [FirebaseData] = []
    var moons: [FirebaseData] = []
    var stars: [FirebaseData] = []
    var dwarfPlanets: [FirebaseData] = []
    
    var filteredPlanets: [FirebaseData] = []
    var filteredMoons: [FirebaseData] = []
    var filteredStars: [FirebaseData] = []
    var filteredDwarfPlanets: [FirebaseData] = []
    
    var collectionStar: String {
        return currentLanguage == "fr" ? "stars" : "starsEn"
    }
    var collectionPlanet: String {
        return currentLanguage == "fr" ? "planets" : "planetsEn"
    }
    var collectionDwarfPlanet: String {
        return currentLanguage == "fr" ? "dwarfPlanets" : "dwarfPlanets"
    }
    var collectionMoon: String {
        return currentLanguage == "fr" ? "moons" : "moonsEn"
    }
    var collectionArticle: String {
        return currentLanguage == "fr" ? "article" : "articleEn"
    }
    var unit: String {
        return currentLanguage == "fr" ? "km" : "mi"
    }
    var placeHolder: String {
        return currentLanguage == "fr" ? "Rechercher dans le Système Solaire" : "Search in Solar System"
    }
    
    var saveTitleAlert: String {
        return currentLanguage == "fr" ? "Sauvegardé" : "Saved"
    }
    
    var deleteTitleAlert: String {
        return currentLanguage == "fr" ? "Effacé" : "Deleted"
    }
}

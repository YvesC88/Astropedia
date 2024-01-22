//
//  SolarSystemViewModel.swift
//  Astropedia
//
//  Created by Yves Charpentier on 20/09/2023.
//

import Foundation
import Combine

enum CelestialCategory {
    static let all = "Tout"
    static let stars = "Étoiles"
    static let planets = "Planètes"
    static let dwarfPlanets = "Pl. naines"
    static let moons = "Lunes"
}

class SolarSystemViewModel: NSObject {
    
    let solarSystemService = SolarSystemService(wrapper: FirebaseWrapper())
    var solarSystem: [SolarSystemCategory] = []
    
    @Published var planets: [SolarSystem] = []
    @Published var moons: [SolarSystem] = []
    @Published var stars: [SolarSystem] = []
    @Published var dwarfPlanets: [SolarSystem] = []
    
    override init() {
        super.init()
        loadSolarSystem()
    }
    
    private final func loadSolarSystem() {
        solarSystemService.fetchSolarSystem(collectionID: "planets") { planet, error in
            if let planet = planet {
                self.planets = planet
                self.updateSolarSystem()
            }
        }
        
        solarSystemService.fetchSolarSystem(collectionID: "dwarfPlanets") { dwarfPlanets, error in
            if let dwarfPlanets = dwarfPlanets {
                self.dwarfPlanets = dwarfPlanets
                self.updateSolarSystem()
            }
        }
        
        solarSystemService.fetchSolarSystem(collectionID: "moons") { moon, error in
            if let moon = moon {
                self.moons = moon
                self.updateSolarSystem()
            }
        }
        
        solarSystemService.fetchSolarSystem(collectionID: "stars") { star, error in
            if let star = star {
                self.stars = star
                self.updateSolarSystem()
            }
        }
    }
    
    private final func updateSolarSystem() {
        if planets.isEmpty, stars.isEmpty, moons.isEmpty, dwarfPlanets.isEmpty {
//            presentAlert(title: "Erreur", message: "Une erreur est survenue lors du chargement")
        } else {
            let starsCategories = SolarSystemCategory(name: CelestialCategory.stars, data: stars)
            let planetsCategories = SolarSystemCategory(name: CelestialCategory.planets, data: planets)
            let dwarfsPlanetsCategories = SolarSystemCategory(name: CelestialCategory.dwarfPlanets, data: dwarfPlanets)
            let moonsCategories = SolarSystemCategory(name: CelestialCategory.moons, data: moons)
            
            solarSystem = [starsCategories, planetsCategories, dwarfsPlanetsCategories, moonsCategories]
        }
    }
}

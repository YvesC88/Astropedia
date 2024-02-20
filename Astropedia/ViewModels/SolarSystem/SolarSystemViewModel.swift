//
//  SolarSystemViewModel.swift
//  Astropedia
//
//  Created by Yves Charpentier on 20/09/2023.
//

import Foundation
import Combine

enum ScopeButtonCategories {
    static let all = "Tout"
    static let stars = "Étoiles"
    static let planets = "Planètes"
    static let dwarfPlanets = "Pl. naines"
    static let moons = "Lunes"
}

// Pourquoi faire herite de NSObject, a eviter autant que possible, il y a un manque de comprehension je crois sur l'heritage et les init et override et les convenience et designated init. Regarde a nouveau la doc a ce sujet ;)
final class SolarSystemViewModel {

    let solarSystemService = SolarSystemService(wrapper: FirebaseWrapper())
    var solarSystem: [SolarSystemCategory] = []
    
    // L'objectif ici dans tes VM c'est que ces property soit en private(set) si ton VC les modifie alors tu tues le pattern MVVM. Seulement le VM decide et format les data. Ta view et donc ton VC ne fait que transmettre des infos comme les event de tap ou de rafraichissement de la vue rien d'autre.
    @Published private(set) var planets: [SolarSystem] = []
    @Published private(set) var moons: [SolarSystem] = []
    @Published private(set) var stars: [SolarSystem] = []
    @Published private(set) var dwarfPlanets: [SolarSystem] = []

    init() {
        loadSolarSystem()
    }
    
    private func loadSolarSystem() {
        // Retain cycle ici si pas de weak self !
        solarSystemService.fetchSolarSystem(collectionID: "planets") { [weak self] planet, error in
            if let planet = planet {
                self?.planets = planet
                self?.updateSolarSystem()
            }
        }
        
        solarSystemService.fetchSolarSystem(collectionID: "dwarfPlanets") { [weak self] dwarfPlanets, error in
            if let dwarfPlanets = dwarfPlanets {
                self?.dwarfPlanets = dwarfPlanets
                self?.updateSolarSystem()
            }
        }
        
        solarSystemService.fetchSolarSystem(collectionID: "moons") { [weak self] moon, error in
            if let moon = moon {
                self?.moons = moon
                self?.updateSolarSystem()
            }
        }
        
        solarSystemService.fetchSolarSystem(collectionID: "stars") { [weak self] star, error in
            if let star = star {
                self?.stars = star
                self?.updateSolarSystem()
            }
        }

        // donc la tu vas call 4x de suite updateSolarSystem? et potentiellement en meme temps ?
        // pas bon tu vas avoir des mauvaises surprises.
        // Tu peux trouver un moyen
    }
    
    private func updateSolarSystem() {
        if planets.isEmpty, stars.isEmpty, moons.isEmpty, dwarfPlanets.isEmpty {
//            presentAlert(title: "Erreur", message: "Une erreur est survenue lors du chargement") // To delete ? ON fait quoi sinon ?
        } else {
            let starsCategories = SolarSystemCategory(name: ScopeButtonCategories.stars, data: stars)
            let planetsCategories = SolarSystemCategory(name: ScopeButtonCategories.planets, data: planets)
            let dwarfsPlanetsCategories = SolarSystemCategory(name: ScopeButtonCategories.dwarfPlanets, data: dwarfPlanets)
            let moonsCategories = SolarSystemCategory(name: ScopeButtonCategories.moons, data: moons)
            
            solarSystem = [starsCategories, planetsCategories, dwarfsPlanetsCategories, moonsCategories]
        }
    }
}

//
//  SolarSystemService.swift
//  Astropedia
//
//  Created by Yves Charpentier on 05/07/2023.
//

import Foundation

final class SolarSystemService {
    
    // MARK: - Properties
    let firebaseWrapper: FirebaseProtocol
    var solarSystemCollection = SolarSystemCollection()
    
    init(wrapper: FirebaseProtocol) {
        self.firebaseWrapper = wrapper
    }
    
    // MARK: - Methods
    final func fetchSolarSystem(collectionID: String, completion: @escaping ([SolarSystem]?, String?) -> ()) {
        firebaseWrapper.fetch(collectionID: collectionID) { data, error in
            if let data = data {
                completion(data, nil)
            } else {
                completion([], error)
            }
        }
    }
    
    final func filterSolarSystem() {
        if solarSystemCollection.isFiltering {
            solarSystemCollection.filteredPlanets = solarSystemCollection.updatePlanets.filter { $0.name.uppercased().hasPrefix(solarSystemCollection.searchText) }
            solarSystemCollection.filteredMoons = solarSystemCollection.updateMoons.filter { $0.name.uppercased().hasPrefix(solarSystemCollection.searchText) }
            solarSystemCollection.filteredStars = solarSystemCollection.updateStars.filter { $0.name.uppercased().hasPrefix(solarSystemCollection.searchText) }
            solarSystemCollection.filteredDwarfPlanets = solarSystemCollection.updateDwarfPlanets.filter { $0.name.uppercased().hasPrefix(solarSystemCollection.searchText) }
        }
    }
}

//
//  PlanetService.swift
//  Planets
//
//  Created by Yves Charpentier on 16/01/2023.
//

import Foundation
import Firebase

class PlanetService {
    // MARK: - Properties
    let firebaseWrapper: FirebaseProtocol
    
    init(wrapper: FirebaseProtocol) {
        self.firebaseWrapper = wrapper
    }
    // MARK: - Methods
    
    // fetch places in FireStore
    func fetchPlanets(collectionID: String, completion: @escaping ([Planet], String?) -> ()) {
        firebaseWrapper.fetch(collectionID: collectionID) { planet, error in
            if let planet = planet {
                completion(planet, nil)
            } else {
                completion([], error)
            }
        }
    }
}

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
}

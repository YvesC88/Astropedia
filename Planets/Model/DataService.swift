//
//  PlanetService.swift
//  Planets
//
//  Created by Yves Charpentier on 16/01/2023.
//

import Foundation
import Firebase

class DataService {
    // MARK: - Properties
    let firebaseWrapper: FirebaseProtocol
    
    init(wrapper: FirebaseProtocol) {
        self.firebaseWrapper = wrapper
    }
    // MARK: - Methods
    
    // fetch places in FireStore
    func fetchData(collectionID: String, completion: @escaping ([Data], String?) -> ()) {
        firebaseWrapper.fetch(collectionID: collectionID) { data, error in
            if let data = data {
                completion(data, nil)
            } else {
                completion([], error)
            }
        }
    }
}

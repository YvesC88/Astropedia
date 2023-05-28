//
//  PlanetService.swift
//  Planets
//
//  Created by Yves Charpentier on 16/01/2023.
//

import Foundation
import Firebase

class FirebaseDataService {
    // MARK: - Properties
    let firebaseWrapper: FirebaseProtocol
    
    init(wrapper: FirebaseProtocol) {
        self.firebaseWrapper = wrapper
    }
    // MARK: - Methods
    
    // fetch places in FireStore
    func fetchData(collectionID: String, completion: @escaping ([FirebaseData], String?) -> ()) {
        firebaseWrapper.fetch(collectionID: collectionID) { data, error in
            if let data = data {
                completion(data, nil)
            } else {
                completion([], error)
            }
        }
    }
    
    func fetchArticle(collectionID: String, completion: @escaping ([FirebaseArticle], String?) -> ()) {
        firebaseWrapper.fetchArticle(collectionID: collectionID) { article, error in
            if let article = article {
                completion(article, nil)
            } else {
                completion([], error)
            }
        }
    }
    
    func fetchPrivacyPolicy(collectionID: String, completion: @escaping ([FirebasePrivacyPolicy], String?) -> ()) {
        firebaseWrapper.fetchPrivacyPolicy(collectionID: "privacyPolicy") { privacyPolicy, error in
            if let privacyPolicy = privacyPolicy {
                completion(privacyPolicy, nil)
            } else {
                completion([], error)
            }
        }
    }
}

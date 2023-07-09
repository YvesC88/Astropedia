//
//  PrivacyPolicyService.swift
//  Planets
//
//  Created by Yves Charpentier on 05/07/2023.
//

import Foundation

class PrivacyPolicyService {
    
    // MARK: - Properties
    let firebaseWrapper: FirebaseProtocol
    
    init(wrapper: FirebaseProtocol) {
        self.firebaseWrapper = wrapper
    }
    
    // MARK: - Methods
    func fetchPrivacyPolicy(collectionID: String, completion: @escaping ([PrivacyPolicy], String?) -> ()) {
        firebaseWrapper.fetchPrivacyPolicy(collectionID: collectionID) { privacyPolicy, error in
            if let privacyPolicy = privacyPolicy {
                completion(privacyPolicy, nil)
            } else {
                completion([], error)
            }
        }
    }
}

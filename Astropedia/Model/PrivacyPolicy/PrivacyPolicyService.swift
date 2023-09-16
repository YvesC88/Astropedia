//
//  PrivacyPolicyService.swift
//  Astropedia
//
//  Created by Yves Charpentier on 05/07/2023.
//

import Foundation

protocol PrivacyPolicyDelegate {
    func displayPrivacyPolicy(title: String, date: String, text: String)
}

class PrivacyPolicyService {
    
    // MARK: - Properties
    let firebaseWrapper: FirebaseProtocol
    var privacyPolicyDelegate: PrivacyPolicyDelegate?
    var privacyPolicy: [PrivacyPolicy] = []
    
    init(wrapper: FirebaseProtocol) {
        self.firebaseWrapper = wrapper
    }
    
    // MARK: - Methods
    final func fetchPrivacyPolicy(collectionID: String, completion: @escaping ([PrivacyPolicy], String?) -> ()) {
        firebaseWrapper.fetchPrivacyPolicy(collectionID: collectionID) { privacyPolicy, error in
            if let privacyPolicy = privacyPolicy {
                completion(privacyPolicy, nil)
            } else {
                completion([], error)
            }
        }
    }
    
    final func loadPrivacyPolicy() {
        fetchPrivacyPolicy(collectionID: "privacyPolicy") { privacyPolicy, error in
            for data in privacyPolicy {
                self.privacyPolicy = privacyPolicy
                self.privacyPolicyDelegate?.displayPrivacyPolicy(title: data.title, date: data.date, text: data.privacyPolicyText.joined(separator: "\n\n"))
            }
        }
    }
}

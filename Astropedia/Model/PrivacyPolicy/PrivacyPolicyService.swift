//
//  PrivacyPolicyService.swift
//  Astropedia
//
//  Created by Yves Charpentier on 05/07/2023.
//

import Foundation

protocol PrivacyPolicyDelegate: AnyObject {
    func displayPrivacyPolicy(title: String, date: String, text: String)
}

final class PrivacyPolicyService {
    
    // MARK: - Properties
    let firebaseWrapper: FirebaseProtocol
    // Un delegate est par definition weak. Sauf rare exception. Ici sans le weak tu as un retain cycle :
    // On a : PrivacyPolicyViewController -> PrivacyPolicyService -> privacyPolicyDelegate (qui est ton PrivacyPolicyViewController)
    weak var privacyPolicyDelegate: PrivacyPolicyDelegate?
    var privacyPolicy: [PrivacyPolicy] = []
    
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
    
    func loadPrivacyPolicy() {
        fetchPrivacyPolicy(collectionID: "privacyPolicy") { privacyPolicy, error in
            for data in privacyPolicy {
                self.privacyPolicy = privacyPolicy
                self.privacyPolicyDelegate?.displayPrivacyPolicy(title: data.title, date: data.date, text: data.privacyPolicyText.joined(separator: "\n\n"))
            }
        }
    }
}

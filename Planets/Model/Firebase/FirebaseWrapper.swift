//
//  FirebaseWrapper.swift
//  Planets
//
//  Created by Yves Charpentier on 16/01/2023.
//

import Firebase

protocol FirebaseProtocol {
    func fetch(collectionID: String, completion: @escaping ([FirebaseData]?, String?) -> ())
}

class FirebaseWrapper: FirebaseProtocol {
    func fetch(collectionID: String, completion: @escaping ([FirebaseData]?, String?) -> ()) {
        let db = Firestore.firestore()
        db.collection(collectionID).addSnapshotListener { (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                completion(self.build(from: querySnapshot.documents), nil)
            } else {
                completion(nil, error?.localizedDescription)
            }
        }
    }
    
    internal func build(from documents: [QueryDocumentSnapshot]) -> [FirebaseData] {
        var planets = [FirebaseData]()
        for document in documents {
            planets.append(FirebaseData(name: document["name"] as? String ?? "",
                                image: document["image"] as? String ?? "",
                                tempMoy: document["tempMoy"] as? String ?? "",
                                gravity: document["gravity"] as? Double ?? 0,
                                statistics: document["statistics"] as? [String] ?? [],
                                source: document["source"] as? String ?? "",
                                membership: document["membership"] as? String ?? "",
                                type: document["type"] as? String ?? "",
                                diameter: document["diameter"] as? Double ?? 0.0))
        }
        return planets
    }
}

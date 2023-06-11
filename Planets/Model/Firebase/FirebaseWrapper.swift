//
//  FirebaseWrapper.swift
//  Planets
//
//  Created by Yves Charpentier on 16/01/2023.
//

import FirebaseFirestore

protocol FirebaseProtocol {
    func fetch(collectionID: String, completion: @escaping ([FirebaseData]?, String?) -> ())
    func fetchArticle(collectionID: String, completion: @escaping ([FirebaseArticle]?, String?) -> ())
    func fetchPrivacyPolicy(collectionID: String, completion: @escaping ([FirebasePrivacyPolicy]?, String?) -> ())
}

class FirebaseWrapper: FirebaseProtocol {
    
    func fetch(collectionID: String, completion: @escaping ([FirebaseData]?, String?) -> ()) {
        let db = Firestore.firestore()
        db.collection(collectionID).addSnapshotListener { (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                completion(self.buildData(from: querySnapshot.documents), nil)
            } else {
                completion(nil, error?.localizedDescription)
            }
        }
    }
    
    internal func buildData(from documents: [QueryDocumentSnapshot]) -> [FirebaseData] {
        var object = [FirebaseData]()
        for document in documents {
            object.append(FirebaseData(name: document["name"] as? String ?? "",
                                       image: document["image"] as? String ?? "",
                                       tempMoy: document["tempMoy"] as? String ?? "",
                                       source: document["source"] as? String ?? "",
                                       membership: document["membership"] as? String ?? "",
                                       type: document["type"] as? String ?? "",
                                       sat: document["sat"] as? Int ?? 0,
                                       gravity: document["gravity"] as? Double ?? 0,
                                       diameter: document["diameter"] as? Double ?? 0,
                                       statistics: document["statistics"] as? [String] ?? [],
                                       galleries: document["galleries"] as? [String] ?? []))
        }
        return object
    }
    
    func fetchArticle(collectionID: String, completion: @escaping ([FirebaseArticle]?, String?) -> ()) {
        let db = Firestore.firestore()
        db.collection(collectionID).addSnapshotListener { (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                completion(self.buildArticle(from: querySnapshot.documents), nil)
            } else {
                completion(nil, error?.localizedDescription)
            }
        }
    }
    
    internal func buildArticle(from documents: [QueryDocumentSnapshot]) -> [FirebaseArticle] {
        var articles = [FirebaseArticle]()
        for document in documents {
            articles.append(FirebaseArticle(title: document["title"] as? String ?? "",
                                            image: document["image"] as? String ?? "",
                                            source: document["source"] as? String ?? "",
                                            subTitle: document["subTitle"] as? String ?? "",
                                            id: document["id"] as? String ?? "",
                                            articleText: document["articleText"] as? [String] ?? []))
        }
        return articles
    }
    
    func fetchPrivacyPolicy(collectionID: String, completion: @escaping ([FirebasePrivacyPolicy]?, String?) -> ()) {
        let db = Firestore.firestore()
        db.collection(collectionID).addSnapshotListener { (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                completion(self.buildPrivacyPolicy(from: querySnapshot.documents), nil)
            } else {
                completion(nil, error?.localizedDescription)
            }
        }
    }
    
    internal func buildPrivacyPolicy(from documents: [QueryDocumentSnapshot]) -> [FirebasePrivacyPolicy] {
        var privacyPolicy = [FirebasePrivacyPolicy]()
        for document in documents {
            privacyPolicy.append(FirebasePrivacyPolicy(title: document["title"] as? String ?? "",
                                                       date: document["date"] as? String ?? "",
                                                       privacyPolicyText: document["privacyPolicyText"] as? [String] ?? []))
        }
        return privacyPolicy
    }
}

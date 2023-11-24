//
//  FirebaseWrapper.swift
//  Astropedia
//
//  Created by Yves Charpentier on 16/01/2023.
//

import FirebaseFirestore

protocol FirebaseProtocol {
    func fetch(collectionID: String, completion: @escaping ([SolarSystem]?, String?) -> ())
    func fetchArticle(collectionID: String, completion: @escaping ([Article]?, String?) -> ())
    func fetchPrivacyPolicy(collectionID: String, completion: @escaping ([PrivacyPolicy]?, String?) -> ())
    func fetchQuestion(collectionID: String, completion: @escaping ([Question]?, String?) -> ())
}

class FirebaseWrapper: FirebaseProtocol {
    
    func fetch(collectionID: String, completion: @escaping ([SolarSystem]?, String?) -> ()) {
        let db = Firestore.firestore()
        db.collection(collectionID).addSnapshotListener { (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                completion(self.buildData(from: querySnapshot.documents), nil)
            } else {
                completion(nil, error?.localizedDescription)
            }
        }
    }
    
    internal func buildData(from documents: [QueryDocumentSnapshot]) -> [SolarSystem] {
        var object = [SolarSystem]()
        for document in documents {
            object.append(SolarSystem(name: document["name"] as? String ?? "",
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
    
    func fetchArticle(collectionID: String, completion: @escaping ([Article]?, String?) -> ()) {
        let db = Firestore.firestore()
        db.collection(collectionID).addSnapshotListener { (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                completion(self.buildArticle(from: querySnapshot.documents), nil)
            } else {
                completion(nil, error?.localizedDescription)
            }
        }
    }
    
    internal func buildArticle(from documents: [QueryDocumentSnapshot]) -> [Article] {
        var articles = [Article]()
        for document in documents {
            articles.append(Article(title: document["title"] as? String ?? "",
                                    image: document["image"] as? String ?? "",
                                    source: document["source"] as? String ?? "",
                                    subtitle: document["subTitle"] as? String ?? "",
                                    id: document["id"] as? String ?? "",
                                    articleText: document["articleText"] as? [String] ?? []))
        }
        return articles
    }
    
    func fetchPrivacyPolicy(collectionID: String, completion: @escaping ([PrivacyPolicy]?, String?) -> ()) {
        let db = Firestore.firestore()
        db.collection(collectionID).addSnapshotListener { (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                completion(self.buildPrivacyPolicy(from: querySnapshot.documents), nil)
            } else {
                completion(nil, error?.localizedDescription)
            }
        }
    }
    
    internal func buildPrivacyPolicy(from documents: [QueryDocumentSnapshot]) -> [PrivacyPolicy] {
        var privacyPolicy = [PrivacyPolicy]()
        for document in documents {
            privacyPolicy.append(PrivacyPolicy(title: document["title"] as? String ?? "",
                                               date: document["date"] as? String ?? "",
                                               privacyPolicyText: document["privacyPolicyText"] as? [String] ?? []))
        }
        return privacyPolicy
    }
    
    func fetchQuestion(collectionID: String, completion: @escaping ([Question]?, String?) -> ()) {
        let db = Firestore.firestore()
        db.collection(collectionID).addSnapshotListener { (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                completion(self.buildQuestion(from: querySnapshot.documents), nil)
            } else {
                completion(nil, error?.localizedDescription)
            }
        }
    }
    
    internal func buildQuestion(from documents: [QueryDocumentSnapshot]) -> [Question] {
        var question = [Question]()
        for document in documents {
            question.append(Question(text: document["text"] as? String ?? "",
                                     answer: document["answer"] as? Bool ?? false))
        }
        return question
    }
}

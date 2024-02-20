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

final class FirebaseWrapper: FirebaseProtocol {

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
    
    // Internal n'a pas d'utilite ici car ta class est defini en internal (rien = internal) donc cette methode est deja internal
    func buildData(from documents: [QueryDocumentSnapshot]) -> [SolarSystem] {
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
    
    func buildArticle(from documents: [QueryDocumentSnapshot]) -> [Article] {
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
    
    func buildPrivacyPolicy(from documents: [QueryDocumentSnapshot]) -> [PrivacyPolicy] {
        var privacyPolicy = [PrivacyPolicy]()
        for document in documents {
            privacyPolicy.append(PrivacyPolicy(title: document["title"] as? String ?? "",
                                               date: document["date"] as? String ?? "",
                                               privacyPolicyText: document["privacyPolicyText"] as? [String] ?? []))
        }
        return privacyPolicy
    }
    
    // Ta completion prend un array de question en optionel et une string optionel.. Le soucis ici c'est qu'on ne sait pas ce que c'est derriere la string. Surtout que le naming de la func est fetch questions. On s'attend pas a avoir une string en plus. Idem pour les autres func plus haut ;)
    // Donc pour deviner il faut lire l'implementation/le code. Si j'ai bien compris c'est une description d'erreur. C'est pas judicieux ici, je te conseille plutot de retourner le type error ca permettra aussi de mieux comprendre les types de la completion. Error vs String. Retient que c'est pas une bonne pratique du tout de retourner une string a la place d'une error. Il faut retourner le type error et la string sera utiliser a la fin pour une alert utilisateur (dans la view)
    // L'autre soucis c'est d'avoir des optionel partout et donc plein de cas possibles (2^2 = 4)
    // Plusieurs suggestions :
    // 1. Utiliser le type Result pour gerer soit le success soit la failure du fetch : Result<[Question], Error>
    // 2. creer un typealias de ta completion : typealias FetchQuestionCompletion = (Result<[Question], Error>) -> ()
    // Ca devient :
    // func fetchQuestion(collectionID: String, completion: @escaping FetchQuestionCompletion)
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

    // Exemple ici:
    typealias FetchQuestionCompletion = (Result<[Question], Error>) -> ()

    // Voila la nouvelle func :
    func fetchQuestion(collectionID: String, completion: @escaping FetchQuestionCompletion) {
        let db = Firestore.firestore()
        db.collection(collectionID).addSnapshotListener { (querySnapshot, error) in
            if let error {
                completion(.failure(error))
                return
            }
            
            if let querySnapshot {
                completion(.success(self.buildQuestion(from: querySnapshot.documents)))
            } else {
                // Important ce cas aussi: pas d'erreur mais pas de data
                completion(.success([]))
            }
        }
    }

    // Je pense que ca vaudrait le coup que tu check a nouveau la diff entre internal, private, fileprivate, open, public, etc.
    // il y a `package` qui vient de sortir aussi ;)
    // *buildQuestions
    func buildQuestion(from documents: [QueryDocumentSnapshot]) -> [Question] {
        var question = [Question]()
        for document in documents {
            question.append(Question(text: document["text"] as? String ?? "",
                                     answer: document["answer"] as? Bool ?? false))
        }
        return question
    }
}

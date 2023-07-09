//
//  FirebaseWrapperMock.swift
//  PlanetsTests
//
//  Created by Yves Charpentier on 24/01/2023.
//

@testable import Planets

final class FirebaseWrapperMock: FirebaseProtocol {

    var dataResult: [FirebaseSolarSystem]?
    var articleRestult: [FirebaseArticle]?
    var privacyPolicyResult: [FirebasePrivacyPolicy]?
    var dataError: String?
    var articleError: String?
    var privacyPolicyError: String?
    var isFetchDataCalled: Bool = false
    var isFetchArticleCalled: Bool = false
    var isFetchPrivacyCalled: Bool = false

    func fetch(collectionID: String, completion: @escaping ([FirebaseSolarSystem]?, String?) -> ()) {
        isFetchDataCalled = true
        completion(dataResult, dataError)
    }

    func fetchArticle(collectionID: String, completion: @escaping ([FirebaseArticle]?, String?) -> ()) {
        isFetchArticleCalled = true
        completion(articleRestult, articleError)
    }

    func fetchPrivacyPolicy(collectionID: String, completion: @escaping ([FirebasePrivacyPolicy]?, String?) -> ()) {
        isFetchPrivacyCalled = true
        completion(privacyPolicyResult, privacyPolicyError)
    }
}

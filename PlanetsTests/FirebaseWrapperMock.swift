//
//  FirebaseWrapperMock.swift
//  AstropediaTests
//
//  Created by Yves Charpentier on 24/01/2023.
//

@testable import Astropedia

final class FirebaseWrapperMock: FirebaseProtocol {

    var dataResult: [SolarSystem]?
    var articleRestult: [Article]?
    var privacyPolicyResult: [PrivacyPolicy]?
    var dataError: String?
    var articleError: String?
    var privacyPolicyError: String?
    var isFetchDataCalled: Bool = false
    var isFetchArticleCalled: Bool = false
    var isFetchPrivacyCalled: Bool = false

    func fetch(collectionID: String, completion: @escaping ([SolarSystem]?, String?) -> ()) {
        isFetchDataCalled = true
        completion(dataResult, dataError)
    }

    func fetchArticle(collectionID: String, completion: @escaping ([Article]?, String?) -> ()) {
        isFetchArticleCalled = true
        completion(articleRestult, articleError)
    }

    func fetchPrivacyPolicy(collectionID: String, completion: @escaping ([PrivacyPolicy]?, String?) -> ()) {
        isFetchPrivacyCalled = true
        completion(privacyPolicyResult, privacyPolicyError)
    }
}

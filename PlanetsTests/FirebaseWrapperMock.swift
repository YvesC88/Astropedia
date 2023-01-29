//
//  FirebaseWrapperMock.swift
//  PlanetsTests
//
//  Created by Yves Charpentier on 24/01/2023.
//

@testable import Planets

final class FirebaseWrapperMock: FirebaseProtocol {
    var dataResult: [Data]?
    var dataError: String?
    var isFetchDataCalled: Bool = false
    
    func func fetch(collectionID: String, completion: @escaping ([Data]?, String?) -> ()) {
        isFetchDataCalled = true
        completion(dataResult, dataError)
    }
}

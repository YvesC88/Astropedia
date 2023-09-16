//
//  DataServiceTest.swift
//  AstropediaTests
//
//  Created by Yves Charpentier on 24/01/2023.
//

import XCTest
@testable import Astropedia

final class DataServiceTest: XCTestCase {
    
    let firebaseMock = FirebaseWrapperMock()
    
    func testGivenDataTestWhenFetchPlaceThenFetchIsOK() {
        // Given
        let expectation = XCTestExpectation(description: "Wait for queue change.")
        
        let firebaseDataService = FirebaseDataService(wrapper: firebaseMock)
        firebaseMock.dataResult = [FirebaseSolarSystem(name: "Terre",
                                                 image: "",
                                                 tempMoy: "",
                                                 source: "",
                                                 membership: "",
                                                 type: "",
                                                 gravity: nil,
                                                 diameter: nil,
                                                 statistics: [],
                                                 galleries: [])]
        firebaseMock.dataError = nil
        
        var resultData: [FirebaseSolarSystem]?
        var resultError: String?
        // When
        firebaseDataService.fetchData(collectionID: "test") { data, error in
            resultData = data
            resultError = error
            expectation.fulfill()
        }
        // Then
        wait(for: [expectation], timeout: 0.01)
        XCTAssertEqual(resultData
        XCTAssertEqual(resultData[0].name, "Terre")
        XCTAssertNil(resultError)
        XCTAssertTrue(firebaseMock.isFetchDataCalled)
    }
    

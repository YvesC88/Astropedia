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
        let solarSystemService = SolarSystemService(wrapper: firebaseMock)
        firebaseMock.dataResult = [SolarSystem(name: "Terre",
                                               image: "",
                                               tempMoy: "",
                                               source: "",
                                               membership: "",
                                               type: "",
                                               sat: 0,
                                               gravity: 0,
                                               diameter: 0,
                                               statistics: [],
                                               galleries: [])]
        firebaseMock.dataError = nil
        
        var resultData: [SolarSystem]?
        var resultError: String?
        // When
        solarSystemService.fetchSolarSystem(collectionID: "test") { data, error in
            resultData = data
            resultError = error
            expectation.fulfill()
        }
        // Then
        wait(for: [expectation], timeout: 0.01)
        XCTAssertEqual(resultData![0].name, "Terre")
        XCTAssertNil(resultError)
        XCTAssertTrue(firebaseMock.isFetchDataCalled)
    }
    
    func testGivenDataTestWhenFetchPlaceThenFetchIsKO() {
        // Given
        let expectation = XCTestExpectation(description: "Wait for queue change.")
        let solarSystemService = SolarSystemService(wrapper: firebaseMock)
        firebaseMock.dataResult = nil
        firebaseMock.dataError = "error"
        
        var resultData: [SolarSystem]?
        var resultError: String?
        
        // When
        solarSystemService.fetchSolarSystem(collectionID: "test") { data, error in
            resultData = data
            resultError = error
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 0.01)
        XCTAssertEqual(resultData, [])
        XCTAssertEqual(resultError, "error")
        XCTAssertTrue(firebaseMock.isFetchDataCalled)
    }

}

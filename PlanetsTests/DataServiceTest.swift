//
//  DataServiceTest.swift
//  PlanetsTests
//
//  Created by Yves Charpentier on 24/01/2023.
//

import XCTest
@testable import Planets

final class DataServiceTest: XCTestCase {
    
    let firebaseMock = FirebaseWrapperMock()
    
    func testGivenDataTestWhenFetchPlaceThenFetchIsOK() {
        // Given
        let expectation = XCTestExpectation(description: "Wait for queue change.")
        let dataService = DataService(wrapper: firebaseMock)
        firebaseMock.dataResult = [
        firebaseMock.placeResult = [Place(name: "Test",
                                          streetNumber: "",
                                          streetName: "",
                                          city: "",
                                          category: "",
                                          zip: 12345,
                                          lat: 1.0,
                                          long: 1.1)]
        firebaseMock.placeError = nil

        var resultPlace: [Place]?
        var resultError: String?
        // When
        placeService.fetchPlaces(collectionID: "test") { (result, error) in
            resultPlace = result
            resultError = error
            expectation.fulfill()
        }
        // Then
        wait(for: [expectation], timeout: 0.01)
        XCTAssertEqual(resultPlace?[0].name, "Test")
        XCTAssertNil(resultError)
        XCTAssertTrue(firebaseMock.isFetchPlaceCalled)
    }
    
    func testGivenDataTestWhenFetchPlaceThenFetchIsKO() {
        // Given
        let expectation = XCTestExpectation(description: "Wait for queue change.")
        let placeService = PlaceService(wrapper: firebaseMock)
        firebaseMock.placeError = "error"

        var resultError: String?
        // When
        placeService.fetchPlaces(collectionID: "test") { (result, error) in
            resultError = error
            expectation.fulfill()
        }
        // Then
        wait(for: [expectation], timeout: 0.01)
        XCTAssertEqual(resultError, "error")
        XCTAssertTrue(firebaseMock.isFetchPlaceCalled)
    }
}


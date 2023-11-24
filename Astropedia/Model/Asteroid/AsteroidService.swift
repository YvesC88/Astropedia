//
//  AsteroidService.swift
//  Astropedia
//
//  Created by Yves Charpentier on 31/03/2023.
//

import Foundation

enum ResultError: Error {
    case invalidUrl, invalidResponse, invalidResult
}

class AsteroidService {
    
    final func getValue(startDate: String, endDate: String) async throws -> ResultAsteroid {
        let endPoint = Constant.baseUrl + Constant.apiAsteroid + Constant.apiKey + Constant.startDate + "\(startDate)" + Constant.endDate + "\(endDate)"
        guard let url = URL(string: endPoint) else { throw ResultError.invalidUrl }
        let (result, response) = try await URLSession.shared.data(from: url)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw ResultError.invalidResponse
        }
        do {
            return try JSONDecoder().decode(ResultAsteroid.self, from: result)
        } catch {
            throw ResultError.invalidResult
        }
    }
}

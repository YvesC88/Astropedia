//
//  AsteroidService.swift
//  Planets
//
//  Created by Yves Charpentier on 31/03/2023.
//

import Alamofire
import Foundation

protocol AsteroidDelegate {
    func numberAsteroids(value: Int)
    func reloadAsteroidTableView()
    func presentMessage(title: String, message: String)
    func animatingSpinner()
}

class AsteroidService {
    
    private var apiKey = ApiKeys()
    var result: [APIAsteroid] = [] {
        didSet {
            asteroidDelegate?.reloadAsteroidTableView()
        }
    }
    var asteroidDelegate: AsteroidDelegate?
    
    final func getValue(startDate: String, endDate: String, callback: @escaping (ResultAsteroid?) -> Void) {
        let url = "https://api.nasa.gov/neo/rest/v1/feed"
        let parameters = [
            "api_key": apiKey.keyNasa ?? "",
            "start_date": startDate,
            "end_date": endDate,
        ] as [String : Any]
        
        AF.request(url, method: .get, parameters: parameters).response { response in
            guard let data = response.data else {
                callback(nil)
                return
            }
            let response = try? JSONDecoder().decode(ResultAsteroid.self, from: data)
            callback(response)
        }
    }
    
    final func fetchAsteroid(startDate: String, endDate: String) {
        getValue(startDate: startDate, endDate: endDate) { result in
            if let result = result {
                self.asteroidDelegate?.numberAsteroids(value: result.elementCount)
            }
            guard let asteroids = result?.nearEarthObjects.values.flatMap({ $0 }) else {
                self.asteroidDelegate?.presentMessage(title: "Erreur", message: "Erreur réseau")
                return
            }
            self.result = asteroids
            self.asteroidDelegate?.animatingSpinner()
        }
    }
}

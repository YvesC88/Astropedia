//
//  AsteroidService.swift
//  Planets
//
//  Created by Yves Charpentier on 31/03/2023.
//

import Alamofire
import Foundation

class AsteroidService {
    
    private var apiKey = ApiKeys()
    
    func getValue(startDate: String, endDate: String, callback: @escaping (ResultAsteroid?) -> Void) {
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
}

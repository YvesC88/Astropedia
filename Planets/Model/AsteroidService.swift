//
//  AsteroidService.swift
//  Planets
//
//  Created by Yves Charpentier on 31/03/2023.
//

import Alamofire
import Foundation

class AsteroidService {
    
    func getValue(callback: @escaping (ResultAsteroid?) -> Void) {
        let url = "https://api.nasa.gov/neo/rest/v1/feed"
        let parameters = [
            "api_key": "NaNCdJL2CUtgUxl7faub3fEzkEjuEBhyyR0qpy5j",
            "start_date": "2023-03-30",
            "end_date": "2023-03-31"
        ] as [String : Any]
        
        AF.request(url, method: .get, parameters: parameters).response { response in
            guard let data = response.data else {
                callback(nil)
                return
            }
            let welcome = try? JSONDecoder().decode(ResultAsteroid.self, from: data)
            callback(welcome)
        }
    }
}

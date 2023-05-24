//
//  APIApod.swift
//  Planets
//
//  Created by Yves Charpentier on 23/04/2023.
//

import Foundation

struct APIApod: Codable {
    let date, explanation: String
    let copyright: String?
    let hdurl: String
    let mediaType, serviceVersion, title: String
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case copyright, date, explanation, hdurl
        case mediaType = "media_type"
        case serviceVersion = "service_version"
        case title, url
    }
}

extension APIApod {
    
    func toPicture(completion: @escaping (Picture?) -> Void) {
        var picture = Picture(title: self.title,
                              image: nil,
                              copyright: self.copyright,
                              explanation: self.explanation)
        
        if let image = URL(string: self.url) {
            URLSession.shared.dataTask(with: image) { data, response, error in
                guard let data = data, error == nil else {
                    completion(nil)
                    return
                }
                picture.image = data
                completion(picture)
            }
            .resume()
        } else {
            completion(nil)
        }
    }
}

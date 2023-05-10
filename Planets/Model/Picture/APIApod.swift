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
    
    func toPicture() -> Picture {
        var picture = Picture(title: self.title,
                              imageSD: nil,
                              imageHD: nil,
                              copyright: self.copyright,
                              explanation: self.explanation)
        let group = DispatchGroup()
        if let sdURL = URL(string: self.url) {
            group.enter()
            URLSession.shared.dataTask(with: sdURL) { data, response, error in
                defer { group.leave() }
                guard let data = data, error == nil else { return }
                picture.imageSD = data
            }
            .resume()
        }
        if let hdURL = URL(string: self.hdurl) {
            group.enter()
            URLSession.shared.dataTask(with: hdURL) { data, response, error in
                defer { group.leave() }
                guard let data = data, error == nil else { return }
                picture.imageHD = data
            }
            .resume()
        }
        group.wait()
        return picture
    }
}

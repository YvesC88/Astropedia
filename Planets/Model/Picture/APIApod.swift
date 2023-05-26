//
//  APIApod.swift
//  Planets
//
//  Created by Yves Charpentier on 23/04/2023.
//

import Foundation
import SDWebImage

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
        return Picture(title: self.title, image: self.hdurl, copyright: self.copyright, explanation: self.explanation)
    }
}

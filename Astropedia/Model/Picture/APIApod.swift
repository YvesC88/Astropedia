//
//  APIApod.swift
//  Astropedia
//
//  Created by Yves Charpentier on 23/04/2023.
//

import Foundation

struct APIApod: Codable {
    let date, explanation: String
    let copyright: String?
    let hdurl: String?
    let mediaType, serviceVersion, title: String
    let url: String?
    
    enum CodingKeys: String, CodingKey {
        case copyright, date, explanation, hdurl
        case mediaType = "media_type"
        case serviceVersion = "service_version"
        case title, url
    }
}

extension APIApod {
    
    func toPicture() -> Picture {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "us_US")
        let date = dateFormatter.date(from: self.date) ?? Date()
        dateFormatter.dateFormat = "dd MM yyyy"
        dateFormatter.locale = Locale(identifier: "fr_FR")
        let finalDate = dateFormatter.string(from: date)
        return Picture(title: self.title,
                       date: finalDate,
                       videoURL: self.url,
                       imageURL: self.hdurl,
                       mediaType: self.mediaType,
                       copyright: self.copyright,
                       explanation: self.explanation)
    }
}

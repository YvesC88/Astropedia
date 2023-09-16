//
//  LocalPicture.swift
//  Astropedia
//
//  Created by Yves Charpentier on 29/04/2023.
//

import Foundation
import CoreData

class LocalPicture: NSManagedObject { }

extension LocalPicture {
    
    // MARK: - Methods
    
    func toPicture() -> Picture {
        return Picture(title: title,
                       date: date,
                       videoURL: videoURL,
                       imageURL: imageURL,
                       mediaType: mediaType,
                       copyright: copyright,
                       explanation: explanation)
    }
}

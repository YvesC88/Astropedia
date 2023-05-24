//
//  LocalPicture.swift
//  Planets
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
                       image: image,
                       copyright: copyright,
                       explanation: explanation)
    }
}

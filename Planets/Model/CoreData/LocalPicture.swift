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
                       imageSD: imageSD,
                       imageHD: imageHD,
                       copyright: copyright,
                       explanation: explanation)
    }
}

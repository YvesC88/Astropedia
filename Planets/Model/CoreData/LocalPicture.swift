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
        return Picture(title: title, url: url, hdurl: hdurl, copyright: copyright, explanation: explanation)
    }
}

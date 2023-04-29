//
//  PictureService.swift
//  Planets
//
//  Created by Yves Charpentier on 23/04/2023.
//

import Alamofire
import Foundation
import CryptoKit

class PictureService {
    
    func getPicture(callback: @escaping (APIApod?) -> Void) {
        let url = "https://api.nasa.gov/planetary/apod"
        let parameters = [
            "api_key": "NaNCdJL2CUtgUxl7faub3fEzkEjuEBhyyR0qpy5j"
        ] as [String : Any]
        
        AF.request(url, method: .get, parameters: parameters).response { response in
            guard let data = response.data else {
                callback(nil)
                return
            }
            let response = try? JSONDecoder().decode(APIApod.self, from: data)
            callback(response)
        }
    }
    
    func savePicture(title: String?, url: String?, hdurl: String?, copyright: String?, explanation: String?, imageKey: String?)
    {
        let coreDataStack = CoreDataStack()
        let pictures = LocalPicture(context: coreDataStack.viewContext)
        pictures.title = title
        pictures.url = url
        pictures.hdurl = hdurl
        pictures.copyright = copyright
        pictures.explanation = explanation
        pictures
        do {
            try coreDataStack.save()
        } catch {
            print("Erreor \(error)")
        }
    }
    
    func createImageKey(imageData: Data) -> String {
        let hashedData = SHA256.hash(data: imageData)
        let hashedString = hashedData.compactMap { String(format: "%02x", $0) }.joined()
        return hashedString
    }
}

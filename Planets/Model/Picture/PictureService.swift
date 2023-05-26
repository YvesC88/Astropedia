//
//  PictureService.swift
//  Planets
//
//  Created by Yves Charpentier on 23/04/2023.
//

import Alamofire
import Foundation
import CoreData

class PictureService {
    
    private var apiKey = ApiKeys()
    
    func getPicture(startDate: String, endDate: String, callback: @escaping ([APIApod]?) -> Void) {
        let url = "https://api.nasa.gov/planetary/apod"
        let parameters = [
            "api_key": apiKey.keyNasa!,
            "start_date": startDate,
            "end_date": endDate,
        ] as [String : Any]
        
        AF.request(url, method: .get, parameters: parameters).response { response in
            guard let data = response.data else {
                callback(nil)
                return
            }
            let response = try? JSONDecoder().decode([APIApod].self, from: data)
            callback(response)
        }
    }
    
    func savePicture(title: String?, image: String?, copyright: String?, explanation: String?)
    {
        let coreDataStack = CoreDataStack()
        let pictures = LocalPicture(context: coreDataStack.viewContext)
        pictures.title = title
        pictures.image = image
        pictures.copyright = copyright
        pictures.explanation = explanation
        do {
            try coreDataStack.save()
        } catch {
            print("Error \(error)")
        }
    }
    
    func unsaveRecipe(picture: Picture) {
        do {
            try CoreDataStack.share.unsavePicture(picture: picture)
        } catch {
            print("Error : \(error)")
        }
    }
    
    func isFavorite(picture: Picture) -> Bool {
        let context = CoreDataStack.share.viewContext
        let fetchRequest: NSFetchRequest<LocalPicture> = LocalPicture.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", picture.title ?? "")
        return ((try? context.count(for: fetchRequest)) ?? 0) > 0
    }
}

//
//  PictureService.swift
//  Astropedia
//
//  Created by Yves Charpentier on 23/04/2023.
//

import Alamofire
import Foundation
import CoreData

class PictureService {
    
    private var apiKey = ApiKeys()
    
    let firebaseWrapper: FirebaseProtocol
    
    init(wrapper: FirebaseProtocol) {
        self.firebaseWrapper = wrapper
    }
    
//    final func getPicture(startDate: String, endDate: String) async throws -> APIApod {
//        let endPoint = "https://api.nasa.gov/planetary/apod?api_key=\(apiKey.keyNasa)&start_date=\(startDate)&end_date=\(endDate)"
//        guard let url = URL(string: endPoint) else { throw ResultError.invalidUrl }
//        let (result, response) = try await URLSession.shared.data(from: url)
//        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
//            throw ResultError.invalidResponse
//        }
//        do {
//            return try JSONDecoder().decode(APIApod.self, from: result)
//        } catch {
//            throw ResultError.invalidResult
//        }
//    }
    
    final func getPicture(startDate: String, endDate: String, callback: @escaping ([APIApod]?) -> Void) {
        let url = "https://api.nasa.gov/planetary/apod"
        let parameters = [
            "api_key": apiKey.keyNasa,
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
    
    final func savePicture(title: String?, videoURL: String?, imageURL: String?, date: String?, mediaType: String?, copyright: String?, explanation: String?)
    {
        let coreDataStack = CoreDataStack()
        let pictures = LocalPicture(context: coreDataStack.viewContext)
        pictures.title = title
        pictures.imageURL = imageURL
        pictures.videoURL = videoURL
        pictures.date = date
        pictures.mediaType = mediaType
        pictures.copyright = copyright
        pictures.explanation = explanation
        do {
            try coreDataStack.save()
        } catch {
            print("Error \(error)")
        }
    }
    
    final func unsaveRecipe(picture: Picture) {
        do {
            try CoreDataStack.share.unsavePicture(picture: picture)
        } catch {
            print("Error : \(error)")
        }
    }
    
    final func isFavorite(picture: Picture) -> Bool {
        let context = CoreDataStack.share.viewContext
        let fetchRequest: NSFetchRequest<LocalPicture> = LocalPicture.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", picture.title ?? "")
        return ((try? context.count(for: fetchRequest)) ?? 0) > 0
    }
}

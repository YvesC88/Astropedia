//
//  PictureService.swift
//  Planets
//
//  Created by Yves Charpentier on 23/04/2023.
//

import Alamofire
import Foundation
import CoreData

protocol PictureDelegate {
    func reloadPictureTableView()
    func showErrorLoading(text: String, isHidden: Bool)
    func startAnimating()
    func stopAnimating()
}

class PictureService {
    
    private var apiKey = ApiKeys()
    var pictureDelegate: PictureDelegate?
    
    let firebaseWrapper: FirebaseProtocol
    
    init(wrapper: FirebaseProtocol) {
        self.firebaseWrapper = wrapper
    }
    
    var picture: [APIApod] = [] {
        didSet {
            pictureDelegate?.reloadPictureTableView()
        }
    }
    
    final func getPicture(startDate: String, endDate: String, callback: @escaping ([APIApod]?) -> Void) {
        let url = "https://api.nasa.gov/planetary/apod"
        let parameters = [
            "api_key": apiKey.keyNasa ?? "",
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
    
    final func savePicture(title: String?, videoURL: String?, imageURL: String?, mediaType: String?, copyright: String?, explanation: String?)
    {
        let coreDataStack = CoreDataStack()
        let pictures = LocalPicture(context: coreDataStack.viewContext)
        pictures.title = title
        pictures.imageURL = imageURL
        pictures.videoURL = videoURL
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
    
    final func getFormattedDate(date: Date, dateFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: date)
    }
    
    final func loadPicture() {
        pictureDelegate?.showErrorLoading(text: "", isHidden: true)
        pictureDelegate?.startAnimating()
        let date = Date()
        let dateFormat = "yyyy-MM-dd"
        let calendar = Calendar.current
        let start = calendar.date(byAdding: .day, value: -1, to: date)
        let startDate = getFormattedDate(date: start ?? Date(), dateFormat: dateFormat)
        let newDate = calendar.date(byAdding: .day, value: -7, to: date)
        let endDate = getFormattedDate(date: newDate ?? Date(), dateFormat: dateFormat)
        getPicture(startDate: endDate, endDate: startDate) { picture in
            if let picture = picture {
                self.picture = picture
            } else {
                self.pictureDelegate?.showErrorLoading(text: "Erreur serveur", isHidden: false)
            }
            self.pictureDelegate?.stopAnimating()
        }
    }
}

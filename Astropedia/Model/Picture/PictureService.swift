//
//  PictureService.swift
//  Astropedia
//
//  Created by Yves Charpentier on 23/04/2023.
//

import Foundation
import CoreData

class PictureService {
    
    let firebaseWrapper: FirebaseProtocol
    let coreDataStack = CoreDataStack()
    
    init(wrapper: FirebaseProtocol) {
        self.firebaseWrapper = wrapper
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
        do { try coreDataStack.save() }
        catch { print("Error \(error)") }
    }
    
    final func unsaveRecipe(picture: Picture) {
        do { try coreDataStack.unsavePicture(picture: picture) }
        catch { print("Error : \(error)") }
    }
    
    final func isFavorite(picture: Picture) -> Bool {
        let context = coreDataStack.viewContext
        let fetchRequest: NSFetchRequest<LocalPicture> = LocalPicture.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "explanation == %@", picture.explanation ?? "")
        return ((try? context.count(for: fetchRequest)) ?? 0) > 0
    }
}

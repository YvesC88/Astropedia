//
//  CoreDataStack.swift
//  Astropedia
//
//  Created by Yves Charpentier on 29/04/2023.
//

import Foundation
import CoreData

protocol CoreDataStackProtocol {
    func save() throws
//    func unSave(uri: String) throws
}

open class CoreDataStack: CoreDataStackProtocol {
    
    
    // MARK: - Properties
    
    private let persistentContainerName = "Astropedia"
    
//    static let share = CoreDataStack()
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
//        return CoreDataStack.share.persistentContainer.viewContext
    }
    
//    init() {}
    
    public lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: persistentContainerName)
        container.loadPersistentStores(completionHandler: { storeDescritpion, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo) for : \(storeDescritpion.description)")
            }
        })
        return container
    }()
    
    
    // MARK: - Methods
    
    func save() throws {
        do { try viewContext.save() }
        catch { print("Error") }
    }

    func unsavePicture(picture: Picture) throws {
        let fetchRequest: NSFetchRequest<LocalPicture>
        fetchRequest = LocalPicture.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", picture.title ?? "")
        let result = try? viewContext.fetch(fetchRequest)
        if let localPicture = result?.first {
            viewContext.delete(localPicture)
            do { try save() }
            catch { print("Error") }
        }
    }
    
    func unsaveArticle(article: Article) throws {
        let fetchRequest: NSFetchRequest<LocalArticle>
        fetchRequest = LocalArticle.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", article.id ?? "")
        let result = try? viewContext.fetch(fetchRequest)
        if let localArticle = result?.first {
            viewContext.delete(localArticle)
            do { try save() }
            catch { print("Error") }
        }
    }
    
    func deleteAllData() throws {
        let entities = persistentContainer.managedObjectModel.entities
        for entity in entities {
            if let entityName = entity.name {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                do {
                    try persistentContainer.persistentStoreCoordinator.execute(deleteRequest, with: viewContext)
                } catch {
                    print("Failed to delete data for entity: \(entityName), error: \(error)")
                    throw error
                }
            }
        }
        try save()
    }
    
    func hasData() -> Bool {
        let entities = persistentContainer.managedObjectModel.entities
        for entity in entities {
            if let entityName = entity.name {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                do {
                    let count = try viewContext.count(for: fetchRequest)
                    if count > 0 {
                        return true
                    }
                } catch {
                    print("Failed to fetch data for entity: \(entityName), error: \(error)")
                }
            }
        }
        return false
    }
}

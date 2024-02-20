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
}

// Pourquoi open ? Je pense que ca n'a pas de sens ici ;)
// Le naming n'est pas bon non plus. Une stack un terme en data structure qui signifie une pile. Autrement dit un array.
// Ca ressemble plutot a ton service Core Data la non ? CoreDataService, ou CoreDataRepository, CoreDataManager (j'evite les manager) mais ici tu as un share donc ca 
open class CoreDataStack: CoreDataStackProtocol {
    
    
    // MARK: - Properties
    
    private let persistentContainerName = "Astropedia"
    
    // Naming pas bon : shared
    static let share = CoreDataStack()
    
    var viewContext: NSManagedObjectContext {
        return CoreDataStack.share.persistentContainer.viewContext
    }
    
    // Private init pour qu'on utilise le shared et qu'il soit initialize une seule fois. C'est le concept du singleton. Utile mais je deconseille. Apres pour un projet comme ca et ton niveau je dis ok.
    private init() {}

    // Public n'a pas de sens ici : si c'est pas clair check doc Swift sur les access modifier
    public lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: persistentContainerName)
        container.loadPersistentStores(completionHandler: { storeDescritpion, error in
            if let error = error as NSError? {
                // Si possible on evite de faire crasher l'app ! La question a se poser est: est-ce vitale pour l'app si tu as une erreur ici ?
                fatalError("Unresolved error \(error), \(error.userInfo) for : \(storeDescritpion.description)")
            }
        })
        return container
    }()
    
    
    // MARK: - Methods
    
    func save() throws {
        do { try viewContext.save() }
        catch { print("Error") } // A ne pas laisser et meme si tu as envie de laisser pourquoi ne pas print l'error du catch directement ?
    }

    // Je pense qu'on ne devrait pas avoir ces notions Produit cad Picture, Article ici dans un service qui est me semble t-il generic d'apres le naming `CoreDataStack`
    func unsavePicture(picture: Picture) throws {
        let fetchRequest: NSFetchRequest<LocalPicture>
        fetchRequest = LocalPicture.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", picture.title ?? "")
        let result = try? viewContext.fetch(fetchRequest)
        if let localPicture = result?.first {
            viewContext.delete(localPicture)
            do { try save() }
            catch { print("Error") } // A ne pas laisser et meme si tu as envie de laisser pourquoi ne pas print l'error du catch directement ?
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
            catch { print("Error") } // A ne pas laisser et meme si tu as envie de laisser pourquoi ne pas print l'error du catch directement ?
            // catch { print("Error: \(error)") }
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

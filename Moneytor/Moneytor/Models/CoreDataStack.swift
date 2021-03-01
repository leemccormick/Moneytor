//
//  CoreDataStack.swift
//  Moneytor
//
//  Created by Lee McCormick on 2/23/21.
//

import CoreData

class CoreDataStack {
    static let shared = CoreDataStack()
    
    // MARK: - Core Data Stack Using CloudKitContainer
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "Moneytor")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print("Error loading persistent stores in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    var context: NSManagedObjectContext {
        let context = CoreDataStack.shared.persistentContainer.viewContext
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.automaticallyMergesChangesFromParent = true
       // context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
    
 
    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

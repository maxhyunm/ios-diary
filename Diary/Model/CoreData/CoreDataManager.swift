//
//  CoreDataManager.swift
//  Diary
//
//  Created by Max, Hemg on 2023/09/01.
//

import CoreData

class CoreDataManager {
    var persistentContainer: NSPersistentContainer
    
    init(entityName: String) {
        persistentContainer = {
            let container = NSPersistentContainer(name: entityName)
            container.loadPersistentStores(completionHandler: { (_, error) in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            })
            return container
        }()
    }
        
    func fetchEntity<T: NSManagedObject>(sortBy: String? = nil) throws -> [T] {
        let request: NSFetchRequest<T> = NSFetchRequest(entityName: persistentContainer.name)
        
        if let sortBy {
            let sorted = NSSortDescriptor(key: sortBy, ascending: false)
            request.sortDescriptors = [sorted]
        }

        do {
            let entities: [T] = try persistentContainer.viewContext.fetch(request)
            return entities
        } catch {
            throw CoreDataError.dataNotFound
        }
    }
    
    func filterEntity<T: NSManagedObject>(_ keyword: String, predicate: String, sortBy: String? = nil) throws -> [T] {
        let request: NSFetchRequest<T> = NSFetchRequest(entityName: persistentContainer.name)
        
        let predicated = NSPredicate(format: predicate, keyword, keyword)
        request.predicate = predicated
        
        if let sortBy {
            let sorted = NSSortDescriptor(key: sortBy, ascending: false)
            request.sortDescriptors = [sorted]
        }
        
        do {
            let entities = try persistentContainer.viewContext.fetch(request)
            return entities
        } catch {
            throw CoreDataError.dataNotFound
        }
    }
    
    func createDiary() -> Diary {
        let newDiary = Diary(context: persistentContainer.viewContext)
        newDiary.id = UUID()
        newDiary.createdAt = Date()
        
        return newDiary
    }
    
    func deleteEntity<T: NSManagedObject>(_ entity: T?) throws {
        guard let entity else {
            throw CoreDataError.deleteFailure
        }
        persistentContainer.viewContext.delete(entity)
        try saveContext()
    }

    func saveContext() throws {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                throw CoreDataError.saveFailure
            }
        }
    }
}

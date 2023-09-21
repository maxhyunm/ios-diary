//
//  CoreDataManager.swift
//  Diary
//
//  Created by Max, Hemg on 2023/09/01.
//

import CoreData

protocol CoreDataManagerProtocol {
    associatedtype Entity where Entity: NSManagedObject
    var persistentContainer: NSPersistentContainer { get set }
}

extension CoreDataManagerProtocol {
    func fetchEntity(predicate: NSPredicate? = nil, sortBy: String? = nil) throws -> [Entity] {
        let request: NSFetchRequest<Entity> = NSFetchRequest(entityName: persistentContainer.name)
        if let predicate {
            request.predicate = predicate
        }
        
        if let sortBy {
            let sorted = NSSortDescriptor(key: sortBy, ascending: false)
            request.sortDescriptors = [sorted]
        }
        
        do {
            let entities: [Entity] = try persistentContainer.viewContext.fetch(request)
            return entities
        } catch {
            throw CoreDataError.dataNotFound
        }
    }
    
    func createData() throws -> Entity {
        let newData = Entity(context: persistentContainer.viewContext)
        try saveContext()
        return newData
    }
    
    func updateData(_ entity: Entity?, key: String?, value: String?) throws {
        guard let entity, let key, let value else {
            throw CoreDataError.updateFailure
        }
        entity.setValue(value, forKey: key)
        try saveContext()
    }

    func deleteData(_ entity: Entity?) throws {
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

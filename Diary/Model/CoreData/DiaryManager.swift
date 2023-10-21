//
//  DiaryManager.swift
//  Diary
//
//  Created by Min Hyun on 2023/09/21.
//

import CoreData

class DiaryManager<Entity: Diary>: CoreDataManagerProtocol {
    var persistentContainer: NSPersistentContainer
    
    init() {
        persistentContainer = {
            let container = NSPersistentContainer(name: "Diary")
            container.loadPersistentStores(completionHandler: { (_, error) in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            })
            return container
        }()
    }
    
    func createDiary() -> Entity {
        let newDiary: Entity = Entity(context: persistentContainer.viewContext)
        newDiary.id = UUID()
        newDiary.createdAt = Date()
        return newDiary
    }
    
    func fetchDiary() throws -> [Entity] {
        let predicated = NSPredicate(format: "title != nil")
        let filtered = try fetchEntity(predicate: predicated, sortBy: "createdAt")
        return filtered
    }
    
    func filterDiary(_ keyword: String) throws -> [Entity] {
        let predicate = "title CONTAINS[cd] %@ OR body CONTAINS[cd] %@ AND title != nil"
        let predicated = NSPredicate(format: predicate, keyword, keyword)
        let filtered = try fetchEntity(predicate: predicated, sortBy: "createdAt")
        
        return filtered
    }
}

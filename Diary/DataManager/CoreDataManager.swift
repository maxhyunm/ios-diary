//
//  CoreDataManager.swift
//  Diary
//
//  Created by Max, Hemg on 2023/09/01.
//

import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    private init() {}
    
    var diaryList = [Diary]()
        
    func createDiary() -> Diary? {
        let newDiary = Diary(context: persistentContainer.viewContext)
        newDiary.id = UUID()
        newDiary.createdAt = Date()
    
        return newDiary
    }
    
    func saveDiary(_ diary: Diary, _ text: String) {
        let contents = text.split(separator: "\n")
        guard !contents.isEmpty,
            let title = contents.first else { return }
        
        let body = contents.dropFirst().joined(separator: "\n")
        
        diary.title = "\(title)"
        diary.body = body
        
        saveContext()
    }
    
    func deleteDiary(_ diary: Diary) {
        persistentContainer.viewContext.delete(diary)
        saveContext()
    }
        
//    private func fetchDiariesSortedㅎByDate() -> [Diary] {
//        let fetchRequest: NSFetchRequest<Diary> = Diary.fetchRequest()
//        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)
//        fetchRequest.sortDescriptors = [sortDescriptor]
//
//        do {
//            let diaries = try persistentContainer.viewContext.fetch(fetchRequest)
//            return diaries
//        } catch {
//            print("Error fetching diaries: \(error)")
//            return []
//        }
//    }
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Diary")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

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

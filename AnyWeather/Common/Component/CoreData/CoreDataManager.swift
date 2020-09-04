//
//  CoreDataClient.swift
//  AnyWeather
//
//  Created by joey.con on 2020/09/03.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import CoreData
import Promises

class CoreDataManager {
    
    static let shared: CoreDataManager = CoreDataManager()
    
    internal lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: CoreDataManager.shared.entityName)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                fatalError("Unresolved error, \((error as NSError).userInfo)")
            }
        })
        return container
    }()
    
    internal lazy var entityName: String = ""
    
    public func getLocalData<Model: NSManagedObject>(_ model: Model.Type,
                                                     entityName: String,
                                                     sortKey: String,
                                                     ascending: Bool = false) -> Promise<[Model]> {
        self.entityName = entityName
        
        let context: NSManagedObjectContext = persistentContainer.viewContext
        let promise: Promise<[Model]> = Promise<[Model]>.pending()
        
        let idSort: NSSortDescriptor = NSSortDescriptor(key: sortKey, ascending: ascending)
        let fetchRequest: NSFetchRequest<NSManagedObject>
            = NSFetchRequest<NSManagedObject>(entityName: entityName)
        fetchRequest.sortDescriptors = [idSort]
        
        do {
            if let fetchResult: [Model] = try context.fetch(fetchRequest) as? [Model] {
                promise.fulfill(fetchResult)
            }
        } catch let error {
            promise.reject(error)
        }
        
        return promise
    }
    
    internal func filteredRequest(id: Int) -> NSFetchRequest<NSFetchRequestResult> {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult>
            = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "id = %@", NSNumber(value: id))
        return fetchRequest
    }
    
    internal func contextSaved(_ context: NSManagedObjectContext) -> Promise<Void> {
        let promise: Promise<Void> = Promise<Void>.pending()
        do {
            try context.save()
            promise.fulfill(())
        } catch let error {
            promise.reject(error)
        }
        return promise
    }
    
    internal func contextAllDeleted() -> Promise<Void> {
        let promise: Promise<Void> = Promise<Void>.pending()
        
        let context: NSManagedObjectContext = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult>
            = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(fetchRequest)
            for object in results {
                guard let objectData = object as? NSManagedObject else { continue }
                context.delete(objectData)
            }
            promise.fulfill(())
        } catch let error {
            promise.reject(error)
        }
        return promise
    }
}

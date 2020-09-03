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
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: CoreDataManager.shared.entityName)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                fatalError("Unresolved error, \((error as NSError).userInfo)")
            }
        })
        return container
    }()
    
    private lazy var entityName: String = ""
    
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
    
    public func saveLocalWeather(_ model: Main.Model.CoreWeatherItem) -> Promise<Void> {
        self.entityName = Main.entityName
        
        let promise = Promise<Void>.pending()
        
        let context: NSManagedObjectContext = persistentContainer.viewContext
        if let entity = NSEntityDescription.entity(forEntityName: Main.entityName, in: context) {
            if let data = NSManagedObject(entity: entity, insertInto: context) as? CoreWeather {
                data.id = Int64(model.id)
                data.city = model.city
                data.lat = model.lat
                data.lon = model.lon
            }
            self.contextSaved(context).then { void in
                promise.fulfill(void)
            }
        }
        
        return promise
    }
    
    private func contextSaved(_ context: NSManagedObjectContext) -> Promise<Void> {
        let promise: Promise<Void> = Promise<Void>.pending()
        do {
            try context.save()
            promise.fulfill(())
        } catch let error {
            promise.reject(error)
        }
        return promise
    }
}

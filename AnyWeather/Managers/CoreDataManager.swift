//
//  CoreDataManager.swift
//  AnyWeather
//
//  Created by hanulyun-tera on 2020/06/08.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit
import CoreData

class CoreDataManager {
    static let shared: CoreDataManager = CoreDataManager()
    
    let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
    lazy var context = appDelegate?.persistentContainer.viewContext
    
    func getData(ascending: Bool = false) -> [Weather] {
        var localDatas: [Weather] = [Weather]()
        
        if let context = context {
            let idSort: NSSortDescriptor = NSSortDescriptor(key: LocalKey.id, ascending: ascending)
            let fetchRequest: NSFetchRequest<NSManagedObject>
                = NSFetchRequest<NSManagedObject>(entityName: LocalKey.model)
            fetchRequest.sortDescriptors = [idSort]
            
            do {
                if let fetchResult: [Weather] = try context.fetch(fetchRequest) as? [Weather] {
                    localDatas = fetchResult
                }
            } catch let error as NSError {
                Log.debug("Could not fetch🥺: \(error), \(error.userInfo)")
            }
        }
        
        return localDatas
    }
    
    
    func saveData(id: Int, city: String, lat: Double, lon: Double,
                       onSuccess: @escaping ((Bool) -> Void)) {
        if let context = context,
            let entity: NSEntityDescription = NSEntityDescription.entity(forEntityName: LocalKey.model,
                                                                         in: context) {
            
            if let data: Weather = NSManagedObject(entity: entity, insertInto: context) as? Weather {
                data.id = Int64(id)
                data.city = city
                data.lat = lat
                data.lon = lon
                
                contextSave { success in
                    onSuccess(success)
                }
            }
        }
    }
    
    func editData(id: Int, city: String, lat: Double, lon: Double,
                       editObject: @escaping ((Weather?) -> Void)) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = filteredRequest(id: id)
        
        do {
            if let result: [Weather] = try context?.fetch(fetchRequest) as? [Weather] {
                if result.count > 0 {
                    result[0].id = Int64(id)
                    result[0].city = city
                    result[0].lat = lat
                    result[0].lon = lon
                }
            }
        } catch let error as NSError {
            Log.debug("Could not fatch🥺: \(error), \(error.userInfo)")
        }
        
        contextSave { [weak self] onSuccess in
            if onSuccess {
                do {
                    if let results: [Weather] = try self?.context?.fetch(fetchRequest) as? [Weather] {
                        editObject(results[0])
                    }
                } catch let error as NSError {
                    editObject(nil)
                    Log.debug("Could not refatch🥺: \(error), \(error.userInfo)")
                }
            }
        }
    }
    
    func deleteData(filterId: Int, onSuccess: @escaping ((Bool) -> Void)) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = filteredRequest(id: filterId)
        
        do {
            if let results: [Weather] = try context?.fetch(fetchRequest) as? [Weather] {
                if results.count != 0 {
                    context?.delete(results[0])
                }
            }
        } catch let error as NSError {
            Log.debug("Could not fatch🥺: \(error), \(error.userInfo)")
            onSuccess(false)
        }
        
        contextSave { success in
            onSuccess(success)
        }
    }
}

extension CoreDataManager {
    private func filteredRequest(id: Int) -> NSFetchRequest<NSFetchRequestResult> {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult>
            = NSFetchRequest<NSFetchRequestResult>(entityName: LocalKey.model)
        fetchRequest.predicate = NSPredicate(format: "\(LocalKey.id) = %@", NSNumber(value: id))
        return fetchRequest
    }
    
    private func contextSave(onSuccess: @escaping ((Bool) -> Void)) {
        do {
            try context?.save()
            onSuccess(true)
        } catch let error as NSError {
            Log.debug("Could not save🥶: \(error), \(error.userInfo)")
            onSuccess(false)
        }
    }
}

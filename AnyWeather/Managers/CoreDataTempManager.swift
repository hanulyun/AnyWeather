//
//  CoreDataManager.swift
//  AnyWeather
//
//  Created by hanulyun-tera on 2020/06/08.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit
import CoreData

struct LocalKey {
    static let model: String = "CoreWeather"
    static let id: String = "id"
    static let city: String = "city"
    static let lat: String = "lat"
    static let lon: String = "lon"
}

class CoreDataTempManager {
    static let shared: CoreDataTempManager = CoreDataTempManager()
    
    enum ResultType {
        case success
        case noMatch
        case error
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: LocalKey.model)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                fatalError("Unresolved error, \((error as NSError).userInfo)")
            }
        })
        return container
    }()
    
    lazy var context = CoreDataTempManager.shared.persistentContainer.viewContext
    
    func getData(ascending: Bool = false) -> [CoreWeather] {
        var localDatas: [CoreWeather] = [CoreWeather]()
        
            let idSort: NSSortDescriptor = NSSortDescriptor(key: LocalKey.id, ascending: ascending)
            let fetchRequest: NSFetchRequest<NSManagedObject>
                = NSFetchRequest<NSManagedObject>(entityName: LocalKey.model)
            fetchRequest.sortDescriptors = [idSort]
            
            do {
                if let fetchResult: [CoreWeather] = try context.fetch(fetchRequest) as? [CoreWeather] {
                    localDatas = fetchResult
                }
            } catch let error as NSError {
                Log.debug("Could not fetch🥺: \(error), \(error.userInfo)")
            }
        
        return localDatas
    }
    
    
    func saveData(id: Int, city: String?, lat: Double, lon: Double,
                  onSuccess: @escaping ((Bool) -> Void)) {
        if let entity: NSEntityDescription = NSEntityDescription.entity(forEntityName: LocalKey.model,
                                                                        in: context) {
            
            if let data: CoreWeather = NSManagedObject(entity: entity, insertInto: context) as? CoreWeather {
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
    
    func editDataList(data: [WeatherModel], onGps: Bool, isEditDone: @escaping ((Bool) -> Void)) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult>
            = NSFetchRequest<NSFetchRequestResult>(entityName: LocalKey.model)
        fetchRequest.returnsObjectsAsFaults = false
        
        // 전체 삭제 후
        do {
            let results = try context.fetch(fetchRequest)
            for object in results {
                guard let objectData = object as? NSManagedObject else { continue }
                context.delete(objectData)
            }
            
        } catch let error as NSError {
            isEditDone(false)
            Log.debug("Could not DeleteAll🥺: \(error), \(error.userInfo)")
        }
        
        // 바뀐 정렬로 다시 저장
        let localCount: Int = onGps ? data.count - 1 : data.count
        var editCount: Int = 0
        
        for (index, weather) in data.enumerated() {
            if index == 0, onGps {
                Log.debug("Gps 날씨 데이터")
            } else {
                self.saveData(id: index,
                              city: weather.city, lat: weather.lat!, lon: weather.lon!) { isSaved in
                    editCount += 1
                }
            }
        }
        isEditDone(editCount == localCount)
    }
    
    func deleteData(filterId: Int, onSuccess: @escaping ((Bool, ResultType) -> Void)) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = filteredRequest(id: filterId)
        
        do {
            if let results: [CoreWeather] = try context.fetch(fetchRequest) as? [CoreWeather] {
                if results.count != 0 {
                    for result in results {
                        context.delete(result)
                    }
                } else {
                    onSuccess(true, .noMatch)
                    return
                }
            }
        } catch let error as NSError {
            Log.debug("Could not fatch🥺: \(error), \(error.userInfo)")
            onSuccess(false, .error)
        }
        
        contextSave { success in
            onSuccess(success, .success)
        }
    }
}

extension CoreDataTempManager {
    private func filteredRequest(id: Int) -> NSFetchRequest<NSFetchRequestResult> {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult>
            = NSFetchRequest<NSFetchRequestResult>(entityName: LocalKey.model)
        fetchRequest.predicate = NSPredicate(format: "\(LocalKey.id) = %@", NSNumber(value: id))
        return fetchRequest
    }
    
    private func contextSave(onSuccess: @escaping ((Bool) -> Void)) {
        do {
            try context.save()
            onSuccess(true)
        } catch let error as NSError {
            Log.debug("Could not save🥶: \(error), \(error.userInfo)")
            onSuccess(false)
        }
    }
}

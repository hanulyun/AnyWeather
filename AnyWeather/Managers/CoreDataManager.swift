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
    
    
    func saveData(id: Int, city: String?, lat: Double, lon: Double,
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
    
    func editDataList(data: [WeatherModel], onGps: Bool, isEditDone: @escaping ((Bool) -> Void)) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult>
            = NSFetchRequest<NSFetchRequestResult>(entityName: LocalKey.model)
        fetchRequest.returnsObjectsAsFaults = false
        
        // 전체 삭제 후
        do {
            if let results = try context?.fetch(fetchRequest) {
                for object in results {
                    guard let objectData = object as? NSManagedObject else { continue }
                    context?.delete(objectData)
                }
            }
        } catch let error as NSError {
            isEditDone(false)
            Log.debug("Could not DeleteAll🥺: \(error), \(error.userInfo)")
        }
        
        // 다시 저장
        let localCount: Int = onGps ? data.count - 1 : data.count
        var editCount: Int = 0
        Log.debug("😀re = \(data.map { ($0.id, $0.city) })")
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

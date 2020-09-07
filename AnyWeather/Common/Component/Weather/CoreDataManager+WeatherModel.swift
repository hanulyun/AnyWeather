//
//  CoreDataManager+WeatherModel.swift
//  AnyWeather
//
//  Created by joey.con on 2020/09/03.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import CoreData
import Promises

private let weatherEntity: String = Main.entityName
extension CoreDataManager {
        
    public func saveLocalWeather(_ model: Main.Model.CoreWeatherItem) -> Promise<Void> {
        self.entityName = weatherEntity
        
        let promise: Promise<Void> = Promise<Void>.pending()
        
        let context: NSManagedObjectContext = persistentContainer.viewContext
        if let entity = NSEntityDescription.entity(forEntityName: entityName, in: context) {
            if let data = NSManagedObject(entity: entity, insertInto: context) as? CoreWeather {
                data.id = Int64(model.id)
                data.city = model.city
                data.lat = model.lat
                data.lon = model.lon
            }
            self.contextSaved(context).then { void in
                promise.fulfill(void)
            }.catch { error in
                promise.reject(error)
            }
        }
        
        return promise
    }
    
    public func deleteLocalWeather(filter id: Int) -> Promise<Void> {
        self.entityName = weatherEntity
        
        let promise: Promise<Void> = Promise<Void>.pending()
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = filteredRequest(id: id)
        let context: NSManagedObjectContext = persistentContainer.viewContext
        do {
            if let results: [CoreWeather] = try context.fetch(fetchRequest) as? [CoreWeather] {
                if results.count != 0 {
                    for result in results {
                        context.delete(result)
                    }
                } else {
                    promise.reject(CoreDataError.noMatchData)
                }
            }
        } catch {
            promise.reject(CoreDataError.contextDeleteFailed)
        }
        
        contextSaved(context).then { void in
            promise.fulfill(void)
        }.catch { error in
            promise.reject(error)
        }
        
        return promise
    }
    
    public func editLocalWeather(_ models: [Main.Model.Weather], onGps: Bool) -> Promise<Void> {
        self.entityName = weatherEntity
        
        let promise: Promise<Void> = Promise<Void>.pending()
        
        contextAllDeleted().then(resavedLocalWeather(models, onGps: onGps)).then {
            promise.fulfill(())
        }.catch { error in
            promise.reject(error)
        }
        
        return promise
    }
    
    private func resavedLocalWeather(_ models: [Main.Model.Weather], onGps: Bool) -> Promise<Void> {
        let promise: Promise<Void> = Promise<Void>.pending()
        
        // 바뀐 정렬로 다시 저장
        let localCount: Int = onGps ? models.count - 1 : models.count
        var editCount: Int = 0
        
        for (index, weather) in models.enumerated() {
            if index == 0, onGps {
                Log.debug("Gps 날씨 데이터 있음")
            } else {
                let item: Main.Model.CoreWeatherItem
                    = Main.Model.CoreWeatherItem(id: index, city: weather.city, lat: weather.lat!, lon: weather.lon!)
                self.saveLocalWeather(item).then {
                    editCount += 1
                    
                    if (models.count - 1) == index {
                        if localCount == editCount {
                            promise.fulfill(())
                        } else {
                            promise.reject(CoreDataError.resaveFailed)
                        }
                    }
                }
            }
        }
        
        return promise
    }
}

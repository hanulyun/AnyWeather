//
//  CoreWeather+CoreDataProperties.swift
//  
//
//  Created by joey.con on 2020/09/03.
//
//

import Foundation
import CoreData


extension CoreWeather {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreWeather> {
        return NSFetchRequest<CoreWeather>(entityName: "CoreWeather")
    }

    @NSManaged public var city: String?
    @NSManaged public var id: Int64
    @NSManaged public var lat: Double
    @NSManaged public var lon: Double

}

extension Main.Model {
    struct CoreWeatherItem {
        let id: Int
        let city: String?
        let lat: Double
        let lon: Double
    }
}

//
//  Weather+CoreDataProperties.swift
//  AnyWeather
//
//  Created by hanulyun-tera on 2020/06/08.
//  Copyright © 2020 hanulyun. All rights reserved.
//
//

import Foundation
import CoreData


extension Weather {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Weather> {
        return NSFetchRequest<Weather>(entityName: "Weather")
    }

    @NSManaged public var id: Int64
    @NSManaged public var lat: Double
    @NSManaged public var lon: Double
    @NSManaged public var city: String?

}

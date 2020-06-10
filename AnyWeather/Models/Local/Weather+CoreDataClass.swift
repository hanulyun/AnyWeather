//
//  Weather+CoreDataClass.swift
//  AnyWeather
//
//  Created by hanulyun-tera on 2020/06/08.
//  Copyright © 2020 hanulyun. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Weather)
public class Weather: NSManagedObject {

}

struct LocalKey {
    static let model: String = "Weather"
    static let id: String = "id"
    static let city: String = "city"
    static let lat: String = "lat"
    static let lon: String = "lon"
}

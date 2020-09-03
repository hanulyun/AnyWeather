//
//  Main.Action.swift
//  AnyWeather
//
//  Created by joey.con on 2020/09/02.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import Promises
import CoreLocation

extension Main.Action {
    static func requestLocationPermission() -> Promise<Void> {
        return CLLocationManager.default.locationRequestWhenInUseAuthorization().recover { error in
            return
        }
    }
    
    static func getSavedLocalWeather() -> Promise<[Model.LocalWeather]> {
        return CoreDataManager.shared
            .getLocalData(Model.LocalWeather.self, entityName: Main.entityName, sortKey: "id")
    }
}

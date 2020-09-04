//
//  List.Action.swift
//  AnyWeather
//
//  Created by joey.con on 2020/09/04.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import Promises

extension List.Action {
    static func deleteLocalWeather(id: Int) -> Promise<Void> {
        return CoreDataManager.shared.deleteLocalWeather(filter: id)
    }
    
    static func updateModels(_ models: [Model.Weather]) -> Promise<Void> {
        let firstModel: Model.Weather? = models.first
        let onGps: Bool = firstModel?.isGps ?? false
        return CoreDataManager.shared.editLocalWeather(models, onGps: onGps)
    }
}

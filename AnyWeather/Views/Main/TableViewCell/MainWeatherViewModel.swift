//
//  MainWeatherViewModel.swift
//  AnyWeather
//
//  Created by Hanul Yun on 2020/06/06.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import Foundation

class MainWeatherViewModel {
    
    func requestCurrentGps(isCompleted: @escaping ((CurrentModel?) -> Void)) {
         // lat: 51.51, lon: -0.13
        APIManager.shared
            .request(CurrentModel.self, url: Urls.current, param: ["q": "seoul"]) { model in
                Log.debug("model = \(model)")
                isCompleted(model)
        }
    }
}

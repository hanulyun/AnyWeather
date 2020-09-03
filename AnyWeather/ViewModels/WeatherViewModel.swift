//
//  MainWeatherViewModel.swift
//  AnyWeather
//
//  Created by Hanul Yun on 2020/06/06.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit
import Promises

// Seoul: lat 37.57, lon 126.98
// 런던: lat 51.51, lon -0.13
class WeatherViewModel: NSObject {
    
    // 외부 접근 변수
    var getGpsFlag: Bool = false
    var unit: TempUnit = .c
    var weatherModels: [WeatherModel] = [WeatherModel]()
    var gpsCity: String?
    var onGps: Bool = false
    
    var currentModels: (([WeatherModel]) -> Void)?
    
    // background에서 foreground로 재진입 시
    func requestWhenForeground() {
        self.weatherModels = []
        
        self.getGpsFlag = false
        self.getSearchWeather()
    }
    
    func requestGpsLocation(lat: Double, lon: Double) {
        self.requestLatLonPoint(lat: lat.description, lon: lon.description) { model in
            if let model: WeatherModel = model {
                self.onGps = true
                
                LocationManager.shared.stopUpdateLocation()
                
                var model: WeatherModel = model
                model.id = 0
                model.city = self.gpsCity
                model.isGps = true
                
                self.weatherModels.insert(model, at: 0)
                self.currentModels?(self.weatherModels)
                Log.debug("GPS 날씨 서버 요청을 하였소")
            } else {
                self.getGpsFlag = false
            }
        }
    }
    
    private func requestSavedLocation(id: Int, city: String?, lat: Double, lon: Double) {
        requestLatLonPoint(lat: lat.description, lon: lon.description) { [weak self] model in
            guard let self = self else { return }
            
            if var model: WeatherModel = model {
                model.id = id
                model.city = city
                model.isGps = false
                self.weatherModels.append(model)
                
                // 정렬
                let sortModel = self.weatherModels.sorted { (model0, model1) -> Bool in
                    (model0.id ?? 0) < (model1.id ?? 0)
                }
                self.weatherModels = sortModel
                
                self.currentModels?(sortModel)
            }
        }
    }
    
    private func requestLatLonPoint(lat: String, lon: String,
                                    isCompleted: @escaping ((WeatherModel?) -> Void)) {
        let param: [String: Any] = [
            ParamKey.lat.rawValue: lat.description,
            ParamKey.lon.rawValue: lon.description,
        ]
        APIManager.shared.request(WeatherModel.self, url: Urls.oneCall, param: param).then { model in
            isCompleted(model)
        }
//        APIManager().request(WeatherModel.self, url: Urls.oneCall, param: param) { (model, error) in
//            if let err: NSError = error as NSError?, err.code == 777 {
//                Log.debug("No Data")
//            }
//
//            isCompleted(model)
//        }
    }
}

// MARK: - LocalData 작업 부분
extension WeatherViewModel {
    func saveSearchWeather(city: String, lat: Double, lon: Double) {
        let allCity: [String?] = weatherModels.map { $0.city }
        if allCity.contains(city) {
            return
        }
        
        let saveId: Int = weatherModels.count
        CoreDataTempManager.shared.saveData(id: saveId, city: city, lat: lat, lon: lon) { [weak self] isSaved in
            if isSaved {
                guard let self = self else { return }
                self.requestSavedLocation(id: saveId, city: city, lat: lat, lon: lon)
            }
        }
    }
    
    func getSearchWeather() {
        let weathers: [CoreWeather] = CoreDataTempManager.shared.getData(ascending: true)
        weathers.forEach {
            requestSavedLocation(id: Int($0.id), city: $0.city, lat: $0.lat, lon: $0.lon)
        }
    }
    
    func deleteWeather(id: Int) {
        CoreDataTempManager.shared.deleteData(filterId: id) { [weak self] isDeleted, type in
            if isDeleted, type == .success {
                guard let self = self else { return }
                self.weatherModels.remove(at: id)
                self.currentModels?(self.weatherModels)
            }
        }
    }
    
    func editWeatherList(models: [WeatherModel], isCompleted: @escaping ((Bool) -> Void)) {
        CoreDataTempManager.shared.editDataList(data: models, onGps: onGps) { [weak self] isDone in
            self?.weatherModels = models
            isCompleted(isDone)
        }
    }
}



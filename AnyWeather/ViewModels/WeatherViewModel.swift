//
//  MainWeatherViewModel.swift
//  AnyWeather
//
//  Created by Hanul Yun on 2020/06/06.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import CoreLocation
import UIKit

// Seoul: lat 37.57, lon 126.98
// 런던: lat 51.51, lon -0.13
class WeatherViewModel: NSObject {
    
    private var gpsIsPermit: ((Bool) -> Void)? // 권한 요청 후 권한 허용 상태에 따라 API 요청
    private var isCompletedGetGps: ((_ lat: CGFloat, _ lon: CGFloat) -> Void)?
    private var getGpsFlag: Bool = false
    
    // 외부 접근 변수
    var unit: TempUnit = .c
    var weatherModels: [WeatherModel] = [WeatherModel]()
    var gpsCity: String?
    var onGps: Bool = false
    
    var currentModels: (([WeatherModel]) -> Void)?
    
    func gpsIsPermitCheck(isPermit: @escaping ((Bool) -> Void)) {
        LocationManager.shared.locationAuthorCall(delegate: self)
        
        gpsIsPermit = { isPermited in
            isPermit(isPermited)
        }
    }
    
    // 현재 위치 날씨 요청
    // 현재 위치를 받아오면 API request 후 model array에 저장
    func requestCurrentGps() {
        LocationManager.shared.locationAuthorizaionCheck(delegate: self) { [weak self] isPermit in
            guard let self = self else { return }
            
            if isPermit {
                LocationManager.shared.startUpdateLocation()
                
                self.isCompletedGetGps = { [weak self] (lat, lon) in
                    guard let self = self else { return }
                    
                    if !self.getGpsFlag {
                        self.getGpsFlag = true
                        
                        self.requestGpsLocation(lat: Double(lat), lon: Double(lon))
                    }
                }
            } else {
                self.onGps = false
            }
        }
    }
    
    // background에서 foreground로 재진입 시
    func requestWhenForeground() {
        self.weatherModels = []
        
        self.getGpsFlag = false
        self.requestCurrentGps()
        self.getSearchWeather()
    }
    
    private func requestGpsLocation(lat: Double, lon: Double) {
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
        APIManager().request(WeatherModel.self, url: Urls.oneCall, param: param) { (model, _) in
            isCompleted(model)
        }
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
        CoreDataManager.shared.saveData(id: saveId, city: city, lat: lat, lon: lon) { [weak self] isSaved in
            if isSaved {
                guard let self = self else { return }
                self.requestSavedLocation(id: saveId, city: city, lat: lat, lon: lon)
            }
        }
    }
    
    func getSearchWeather() {
        let weathers: [Weather] = CoreDataManager.shared.getData(ascending: true)
        weathers.forEach {
            requestSavedLocation(id: Int($0.id), city: $0.city, lat: $0.lat, lon: $0.lon)
        }
    }
    
    func deleteWeather(id: Int) {
        CoreDataManager.shared.deleteData(filterId: id) { [weak self] isDeleted, type in
            if isDeleted, type == .success {
                guard let self = self else { return }
                self.weatherModels.remove(at: id)
                self.currentModels?(self.weatherModels)
            }
        }
    }
    
    func editWeatherList(models: [WeatherModel], isCompleted: @escaping ((Bool) -> Void)) {
        CoreDataManager.shared.editDataList(data: models, onGps: onGps) { [weak self] isDone in
            self?.weatherModels = models
            isCompleted(isDone)
        }
    }
}

// MARK: Location Delegate
extension WeatherViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            LocationManager.shared.requestLocation()
            self.gpsIsPermit?(true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations[locations.count - 1]
        let longitude: CLLocationDegrees = location.coordinate.longitude
        let latitude: CLLocationDegrees = location.coordinate.latitude
        
        self.isCompletedGetGps?(CGFloat(latitude), CGFloat(longitude))
                
        let findLocation: CLLocation = CLLocation(latitude: latitude, longitude: longitude)
        let geoCoder: CLGeocoder = CLGeocoder()
        let local: Locale = Locale(identifier: "Ko-kr")
        // 위치정보를 사용할 때
        geoCoder.reverseGeocodeLocation(findLocation, preferredLocale: local) { [weak self] (place, error) in
            if let address: [CLPlacemark] = place {
                self?.gpsCity = address.last?.locality
                Log.debug("address = \(String(describing: address.last?.locality))")
            }
            if let error = error {
                Log.debug("errorGeoCoder = \(error.localizedDescription)")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Log.debug("errorManager = \(error)")
    }
}

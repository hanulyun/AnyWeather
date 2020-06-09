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
class MainWeatherViewModel: NSObject {
    
    private var isCompletedGetGps: ((_ lat: CGFloat, _ lon: CGFloat) -> Void)?
    private var getGpsFlag: Bool = false
    
    // 외부 접근 변수
    var unit: TempUnit = .c
    var tempoModel: [WeatherModel] = [WeatherModel]()
    var gpsCity: String?
    var onGps: Bool = false
    
    var currentModels: (([WeatherModel]) -> Void)?
    
    // 현재 위치 날씨 요청
    func requestCurrentGps() {
        LocationManager.shared.locationAuthorizaionCheck(delegate: self) { [weak self] isPermit in
            guard let self = self else { return }
            
            if isPermit {
                LocationManager.shared.startUpdateLocation()
                
                self.isCompletedGetGps = { [weak self] (lat, lon) in
                    guard let self = self else { return }
                    
                    if !self.getGpsFlag {
                        self.getGpsFlag = true
                        
                        self.requestLatLonPoint(lat: lat.description, lon: lon.description) { model in
                            if let model: WeatherModel = model {
                                self.onGps = true
                                
                                LocationManager.shared.stopUpdateLocation()
                                
                                var model: WeatherModel = model
                                model.id = 0
                                model.city = self.gpsCity
                                model.isGps = true
                                
                                self.tempoModel.insert(model, at: 0)
                                self.currentModels?(self.tempoModel)
                            } else {
                                self.getGpsFlag = false
                            }
                        }
                    }
                }
            } else {
                self.onGps = false
            }
        }
    }
    
    // 저장된 지역 날씨 요청. 현재 런던 임시로 호출
    private func requestSavedLocation(id: Int, city: String?, lat: Double, lon: Double) {
        requestLatLonPoint(lat: lat.description, lon: lon.description) { [weak self] model in
            guard let self = self else { return }
            
            if var model: WeatherModel = model {
                model.id = id
                model.city = city
                self.tempoModel.append(model)
            
                // 정렬
                if self.tempoModel.count > 1 {
                    let sortModel = self.tempoModel.sorted { (model0, model1) -> Bool in
                        (model0.id ?? 0) < (model1.id ?? 0)
                    }
                    self.tempoModel = sortModel
                }
                
                self.currentModels?(self.tempoModel)
            }
        }
    }
    
    private func requestLatLonPoint(lat: String, lon: String,
                                    isCompleted: @escaping ((WeatherModel?) -> Void)) {
        let param: [String: Any] = [
            ParamKey.lat.rawValue: lat.description,
            ParamKey.lon.rawValue: lon.description,
        ]
        APIManager.shared.request(WeatherModel.self, url: Urls.onecall, param: param) { model in
            isCompleted(model)
        }
    }
}

// MARK: - LocalData 작업 부분
extension MainWeatherViewModel {
    func saveSearchWeather(city: String, lat: Double, lon: Double) {
        let saveId: Int = tempoModel.count
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
        CoreDataManager.shared.deleteData(filterId: id) { [weak self] isDeleted in
            if isDeleted {
                guard let self = self else { return }
                self.tempoModel.remove(at: id)
                self.currentModels?(self.tempoModel)
            }
        }
    }
    
    func editWeatherList(models: [WeatherModel], isCompleted: @escaping ((Bool) -> Void)) {
        CoreDataManager.shared.editDataList(data: models, onGps: onGps) { [weak self] isDone in
            self?.tempoModel = models
            isCompleted(isDone)
        }
    }
}

extension MainWeatherViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            LocationManager.shared.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations[locations.count - 1]
        let longitude: CLLocationDegrees = location.coordinate.longitude
        let latitude: CLLocationDegrees = location.coordinate.latitude
        
        self.isCompletedGetGps?(CGFloat(latitude), CGFloat(longitude))
                
        // 지역명 찾을 때, 아직 안쓰고 있음.
        let findLocation: CLLocation = CLLocation(latitude: latitude, longitude: longitude)
        let geoCoder: CLGeocoder = CLGeocoder()
        let local = Locale(identifier: "Ko-kr")
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

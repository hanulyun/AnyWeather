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
    
    var tempoModel: [WeatherModel] = [WeatherModel]()
    var currentModels: (([WeatherModel]) -> Void)?
    var gpsCity: String?
    
    // 현재 위치 날씨 요청
    func requestCurrentGps() {
        LocationManager.shared.locationAuthorizaionCheck(delegate: self) { isPermit in
            if isPermit {
                
                LocationManager.shared.startUpdateLocation()
                
                self.isCompletedGetGps = { [weak self] (lat, lon) in
                    guard let self = self else { return }
                    
                    if !self.getGpsFlag {
                        self.getGpsFlag = true
                        
                        self.requestLatLonPoint(lat: lat.description, lon: lon.description) { model in
                            if let model: WeatherModel = model {
                                LocationManager.shared.stopUpdateLocation()
                                
                                var model: WeatherModel = model
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
            }
        }
    }
    
    // 저장된 지역 날씨 요청. 현재 런던 임시로 호출
    func requestSavedLocation() {
        requestLatLonPoint(lat: "51.51", lon: "-0.13") { [weak self] model in
            guard let self = self else { return }
            
            if let model: WeatherModel = model {
                for _ in 0..<3 {
                    self.tempoModel.append(model)
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

extension MainWeatherViewModel: CLLocationManagerDelegate {
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

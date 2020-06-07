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
// lat: 51.51, lon: -0.13 런던
class MainWeatherViewModel: NSObject {
    
    private var isGetGps: ((_ lat: CGFloat, _ lon: CGFloat) -> Void)?
    
    var tempoModel: [WeatherModel] = [WeatherModel]()
    var currentModels: (([WeatherModel]) -> Void)?
    var gpsCity: String?
    
    // 현재 위치 날씨 요청
    func requestCurrentGps() {
        LocationManager.shared.locationAuthorizaionCheck(delegate: self) { isPermit in
            if isPermit {
                
                LocationManager.shared.startUpdateLocation()
                
                self.isGetGps = { [weak self] (lat, lon) in
                    guard let self = self else { return }
                    
                    self.requestLatLonPoint(lat: lat.description, lon: lon.description) { model in
                        
                        LocationManager.shared.stopUpdateLocation()
                        
                        var model: WeatherModel = model
                        model.city = self.gpsCity
                        self.tempoModel.insert(model, at: 0)
                        self.currentModels?(self.tempoModel)
                    }                    
                }
            }
        }
    }
    
    // 저장된 지역 날씨 요청
    func requestSavedLocation() {
        requestLatLonPoint(lat: "51.51", lon: "-0.13") { model in
            for _ in 0..<3 {
                self.tempoModel.append(model)
            }
            
            self.currentModels?(self.tempoModel)
        }
    }
    
    private func requestLatLonPoint(lat: String, lon: String,
                                    isCompleted: @escaping ((WeatherModel) -> Void)) {
        let param: [String: Any] = [
            ParamKey.lat.rawValue: lat.description,
            ParamKey.lon.rawValue: lon.description,
        ]
        APIManager.shared.request(WeatherModel.self, url: Urls.onecall, param: param) { model in
            isCompleted(model)
            Log.debug("model = \(model)")
        }
    }
}

extension MainWeatherViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations[locations.count - 1]
        let longitude: CLLocationDegrees = location.coordinate.longitude
        let latitude: CLLocationDegrees = location.coordinate.latitude
        
        self.isGetGps?(CGFloat(latitude), CGFloat(longitude))
        
        LocationManager.shared.stopUpdateLocation()
        
        // 지역명 찾을 때, 아직 안쓰고 있음.
        let findLocation: CLLocation = CLLocation(latitude: latitude, longitude: longitude)
        let geoCoder: CLGeocoder = CLGeocoder()
        let local = Locale(identifier: "Ko-kr")
        // 위치정보를 사용할 때
        geoCoder.reverseGeocodeLocation(findLocation, preferredLocale: local) { (place, error) in
            if let address: [CLPlacemark] = place {
                self.gpsCity = address.last?.locality
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

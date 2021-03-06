//
//  LocationManager.swift
//  AnyWeather
//
//  Created by Hanul Yun on 2020/06/07.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import MapKit

class LocationManager {
    static let shared: LocationManager = LocationManager()
    
    private let locationManager: CLLocationManager = {
        let manager: CLLocationManager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = kCLHeadingFilterNone
        manager.requestWhenInUseAuthorization()
        return manager
    }()
    
    func locationAuthorCall(delegate: CLLocationManagerDelegate) {
        CLLocationManager.locationServicesEnabled()
        locationManager.delegate = delegate
    }
    
    func locationAuthorizaionCheck(delegate: CLLocationManagerDelegate, isPermited: @escaping ((Bool) -> Void)) {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                Log.debug("location notDetermined")
                isPermited(false)
            case .restricted, .denied:
                Log.debug("위치권한 허용 안함.")
                isPermited(false)
            case .authorizedWhenInUse, .authorizedAlways:
                Log.debug("location 사용 가능")
                locationManager.delegate = delegate
                isPermited(true)
            @unknown default:
                fatalError("locationAuthorizaionCheck error")
            }
        }
    }
    
    func requestLocation() {
        locationManager.requestLocation()
    }
    
    func startUpdateLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdateLocation() {
        locationManager.stopUpdatingLocation()
    }
}

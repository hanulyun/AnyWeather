//
//  LocationClient.swift
//  AnyWeather
//
//  Created by joey.con on 2020/09/02.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import CoreLocation
import Promises

extension CLLocationCoordinate2D {
    static let zero: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0.0, 0.0)
}

class LocationClient: NSObject {
    let locationManager: CLLocationManager = CLLocationManager()
    var pendingPromise: Promise<(CLLocationCoordinate2D, String?)>?
    
    func currentLocation() -> Promise<(CLLocationCoordinate2D, String?)> {
        let authStatus: CLAuthorizationStatus = CLLocationManager.authorizationStatus()
        pendingPromise = Promise<(CLLocationCoordinate2D, String?)>.pending()
        if authStatus == .authorizedWhenInUse {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            return pendingPromise!
        }
        pendingPromise?.fulfill((CLLocationCoordinate2D.zero, nil))
        return pendingPromise!
    }
}

extension LocationClient: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            let findLocation: CLLocation = CLLocation(latitude: location.coordinate.latitude,
                                                      longitude: location.coordinate.longitude)
            let geoCoder: CLGeocoder = CLGeocoder()
            let local: Locale = Locale(identifier: "Ko-kr")
            geoCoder.reverseGeocodeLocation(findLocation, preferredLocale: local) { [weak self] (place, error) in
                if let address: [CLPlacemark] = place {
                    self?.pendingPromise?.fulfill((location.coordinate, address.last?.locality))
                    Log.debug("address = \(String(describing: address.last?.locality))")
                }
                if let error = error {
                    self?.pendingPromise?.reject(error)
                }
            }
        
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        pendingPromise?.fulfill((CLLocationCoordinate2D.zero, nil))
    }
}

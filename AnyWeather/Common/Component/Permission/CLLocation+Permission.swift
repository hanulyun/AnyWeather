//
//  CLLocation+Permission.swift
//  AnyWeather
//
//  Created by joey.con on 2020/09/02.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import CoreLocation
import Promises

enum EmptyError : Error {
    case empty
    case cancel
    
    var localizedDescription: String {
        switch self {
        case .empty:
            return "EmptyError.empty"
        case .cancel:
            return "사용자 취소 (EmptyError.cancel)"
        }
    }
}

private var CLLocationManagerAuthorizationPendingPromiseAssociatedObjectKey: Void?
extension CLLocationManager: CLLocationManagerDelegate {
    static var `default`: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = manager
        return manager
    }()
    
    private var pendingPromise: Promise<Void>? {
        get {
            return objc_getAssociatedObject(self,
                &CLLocationManagerAuthorizationPendingPromiseAssociatedObjectKey) as? Promise<Void>
        }
        set {
            objc_setAssociatedObject(self, &CLLocationManagerAuthorizationPendingPromiseAssociatedObjectKey,
                                     newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    public func locationRequestWhenInUseAuthorization() -> Promise<Void> {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse, .authorizedAlways:
            return Promise(())
        case .notDetermined:
            pendingPromise?.reject(EmptyError.empty)
            pendingPromise = Promise<Void>.pending()
            requestWhenInUseAuthorization()
            return pendingPromise!
        default:
            return Promise(EmptyError.empty)
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            pendingPromise?.fulfill(())
        case .notDetermined:
            return
        default:
            pendingPromise?.reject(EmptyError.empty)
        }
    }
}

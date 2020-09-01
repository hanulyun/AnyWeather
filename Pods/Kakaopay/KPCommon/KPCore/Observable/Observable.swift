//
//  Observable.swift
//  KPCore
//
//  Created by kali_company on 2018. 5. 25..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import Foundation

extension Notification.Name {
    public static let PayObservable = Notification.Name("PayObservableNotification")
}

public protocol Observable: class {
    associatedtype RootType = Self
    
    func postChangeValue<PropertyType>(keyPath: KeyPath<RootType, PropertyType>)
    func didChangeValue<PropertyType>(keyPath: KeyPath<RootType, PropertyType>, oldValue: PropertyType, newValue: PropertyType)
    func removeObserver()
    func addObserver<PropertyType>(keyPath: KeyPath<RootType, PropertyType>, action: @escaping (RootType?, PropertyType, PropertyType) -> Void) -> NSObjectProtocol
}

private var observersAssociatedObjectKey: Void?
extension Observable {
    public func postChangeValue<PropertyType>(keyPath: KeyPath<Self, PropertyType>) {
        var userInfo: [AnyHashable: Any] = ["keyPath": keyPath]
        let value = self[keyPath: keyPath]
        userInfo["oldValue"] = value
        userInfo["newValue"] = value
        NotificationCenter.default.post(name: .PayObservable, object: self, userInfo: userInfo)
    }
    
    public func didChangeValue<PropertyType>(keyPath: KeyPath<Self, PropertyType>, oldValue: PropertyType, newValue: PropertyType) {
        var userInfo: [AnyHashable: Any] = ["keyPath": keyPath]
        userInfo["oldValue"] = oldValue
        userInfo["newValue"] = newValue
        NotificationCenter.default.post(name: .PayObservable, object: self, userInfo: userInfo)
    }
    
    private var notificationObservers: [Any] {
        get {
            guard let observers = objc_getAssociatedObject(self, &observersAssociatedObjectKey) as? [Any] else {
                let newObservers = [Any]()
                objc_setAssociatedObject(self, &observersAssociatedObjectKey, newObservers, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return newObservers
            }
            return observers
        }
        set { objc_setAssociatedObject(self, &observersAssociatedObjectKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    @discardableResult
    public func addObserver<PropertyType>(keyPath: KeyPath<Self, PropertyType>, action: @escaping (Self?, PropertyType, PropertyType) -> Void) -> NSObjectProtocol {
        let observer = NotificationCenter.default.addObserver(forName: .PayObservable, object: self, queue: nil) { [weak self] notification in
            guard let weakSelf = self else { return }
            guard let userInfo = notification.userInfo else { return }
            guard userInfo["keyPath"] as! AnyKeyPath == keyPath else { return }

            let old = (userInfo["oldValue"] as! PropertyType)
            let new = (userInfo["newValue"] as! PropertyType)
            
            action(weakSelf, old, new)
        }
        notificationObservers.append(observer)
        return observer
    }

    public func removeObserver() {
        for notificationObserver in notificationObservers {
            NotificationCenter.default.removeObserver(notificationObserver, name: .PayObservable, object: self)
        }
    }

    public func removeObserver(_ observer: NSObjectProtocol) {
        NotificationCenter.default.removeObserver(observer, name: .PayObservable, object: self)
    }
}

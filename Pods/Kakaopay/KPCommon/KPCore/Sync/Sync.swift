//
//  Sync.swift
//  PayApp
//
//  Created by henry on 28/02/2019.
//  Copyright © 2019 kakaopay. All rights reserved.
//

import UIKit

/*
 앱 전역적으로 값이 동기화 될 필요성이 있는 property 를 편하게 사용할 수 있는 util 클래스 입니다.
 변수를 Sync<Value> 로 선언하면, unique 한 key 값을 기반으로 값 변경사항에 대한 observing 이 자동으로 이루어 집니다.
 value 값 변경과 valueChanged callback 은 편의상 Main Queue 에서 이루어 지며 thread safe 합니다.
 observing 방식은 private NotificationCenter 를 통해 이루어 집니다.
 
 addObserver() 함수를 통해서 값(value) 변화에 대한 observing 을 걸 수 있습니다.
 */
public class Sync<Value>: CustomStringConvertible {
    public var value: Value? {
        get { return _value }
        set {
            _value = newValue
            notificationCenter.update(_value, for: key)
        }
    }
    private var _value: Value?
    
    public var description: String {
        return _value.debugDescription
    }
    
    private var valueChangedObservations = [NSObject: ((Value?) -> Void)]()
    public func addObserver(callImmediately: Bool = false, valueChanged: @escaping (Value?) -> Void) -> NSObjectProtocol {
        let observer = NSObject()
        valueChangedObservations[observer] = valueChanged
        if callImmediately { valueChanged(_value) }
        return observer
    }
    public func removeObserver(_ observer: NSObjectProtocol) {
        guard let observer = observer as? NSObject else {
            return
        }
        valueChangedObservations.removeValue(forKey: observer)
    }
    
    private let notificationCenter: SyncNotificationCenter
    private var key: String
    private var observer: NSObjectProtocol?
    
    public init(_ value: Value? = nil, for key: String, namespace: String = "default") {
        self.notificationCenter = SyncNotificationCenter.center(namespace)
        self.key = key
        if value != nil { self.value = value }
        else { _value = notificationCenter.value(for: key) }
        observer = notificationCenter.observe(for: key) { [weak self] (newValue: Value?) in
            self?._value = newValue
            self?.valueChangedObservations.forEach { (_: NSObject, value: ((Value?) -> Void)) in
                value(newValue)
            }
        }
    }
    
    deinit {
        if let observer = observer {
            notificationCenter.remove(observer: observer)
        }
        valueChangedObservations.removeAll()
    }
}

fileprivate class SyncNotificationCenter: NotificationCenter {
    private static var centerPool = [String: SyncNotificationCenter]()
    static func center(_ domain: String) -> SyncNotificationCenter {
        guard let center: SyncNotificationCenter = centerPool[domain] else {
            let newCenter = SyncNotificationCenter()
            centerPool[domain] = newCenter
            return newCenter
        }
        return center
    }
    private var keyValues = Dictionary<String, Any>()

    func value<Value>(for key: String) -> Value? {
        return keyValues[key] as? Value
    }
    
    func update<Value>(_ newValue: Value, for key: String) {
        // to prevent race condition
        let postNotification = {
            self.keyValues[key] = newValue
            let notification = Notification(name: Notification.Name(key))
            self.post(notification)
        }
        if Thread.isMainThread { postNotification() }
        else { DispatchQueue.main.async { postNotification() } }
    }
    
    func observe<Value>(for key: String, action: @escaping (Value?) -> Void) -> NSObjectProtocol {
        return self.addObserver(forName: NSNotification.Name(rawValue: key), object: nil, queue: nil) { [weak self] notification -> Void in
            let newValue: Value? = self?.keyValues[key] as? Value
            action(newValue)
        }
    }
    
    func remove(observer: NSObjectProtocol) {
        self.removeObserver(observer)
    }
}

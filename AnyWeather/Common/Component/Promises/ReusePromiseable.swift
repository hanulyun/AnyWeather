//
//  ReusePromiseable.swift
//  Kakaopay
//
//  Created by henry on 2018. 5. 9..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import UIKit
import Promises
import Kakaopay

/*
 재사용 가능한 callback closure 를 Promise 와 유사한 네이밍으로 구성한 프로토콜 입니다.
 객체의 life cycle 이후 수행되는 action 을 fulfill(성공), reject(실패) 로 정형화 시켜서 일관성을 가져가도록 합니다.
 (Promiseable 과는 완전히 다른 사용패턴을 가지고 있습니다.)
 
 fulfill, reject property 는 객체의 life cycle 이 완료될때 호출됨이 보장되어야 합니다.
 또한 두 property 는 현재 객체에 retain 되는 함수 이므로 사용시 retain cycle 에 주의해 주세요.
 */
protocol ReusePromiseable: class {
    associatedtype PromiseData
    
    var fulfill: ((PromiseData) -> Promise<Void>)! { get set }
    var reject: ((Error) -> Void)! { get set }
}

private var reuseableFulfillAssociatedObjectKey: Void?
private var reuseableRejectAssociatedObjectKey: Void?
extension ReusePromiseable {
    
    public var fulfill: ((PromiseData) -> Promise<Void>)! {
        get {
            guard let reuseable = objc_getAssociatedObject(self, &reuseableFulfillAssociatedObjectKey) as? ((PromiseData) -> Promise<Void>) else {
                return { _ in return Promise(()) }
            }
            return reuseable
        }
        set { objc_setAssociatedObject(self, &reuseableFulfillAssociatedObjectKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    public var reject: ((Error) -> Void)! {
        get {
            guard let reuseable = objc_getAssociatedObject(self, &reuseableRejectAssociatedObjectKey) as? ((Error) -> Void) else {
                return { _ in return }
            }
            return reuseable
        }
        set { objc_setAssociatedObject(self, &reuseableRejectAssociatedObjectKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}

//
//  ReusePromiseable+Pay.swift
//  PayApp
//
//  Created by henry on 10/04/2019.
//  Copyright © 2019 kakaopay. All rights reserved.
//

import UIKit
import Promises
import Kakaopay

/*
 (UIViewController & ReusePromiseable) 은 viewController dismiss() 를 밖에서 호출하는 패턴으로 사용하는 것을 권장합니다.
 */
extension Pay where Base: (UIViewController & ReusePromiseable) {
    // on 이 UINavigationController 인 경우에는 push 방식으로, 아닌 경우에는 modal 방식으로 present 합니다.
    func presentedOrPushed(on: UIViewController, animated: Bool = true, fulfill: ((Base.PromiseData) -> Promise<Void>)? = nil, reject: ((Error) -> Void)? = nil) {
        if on is UINavigationController {
            pushed(on: on, animated: animated, fulfill: fulfill, reject: reject)
        } else {
            presented(on: on, animated: animated, withNavigationController: true, fulfill: fulfill, reject: reject)
        }
        return
    }
    
    func presented(on: UIViewController, animated: Bool = true, withNavigationController: Bool = false, fulfill: ((Base.PromiseData) -> Promise<Void>)? = nil, reject: ((Error) -> Void)? = nil) {
        if (fulfill != nil) { base.fulfill = fulfill }
        if (reject != nil) { base.reject = reject }
        guard withNavigationController else {
            on.present(base, animated: animated, completion: nil)
            return
        }
        on.present(UINavigationController(rootViewController: base), animated: animated, completion: nil)
        return
    }
    
    func pushed(on: UIViewController, animated: Bool = true, fulfill: ((Base.PromiseData) -> Promise<Void>)? = nil, reject: ((Error) -> Void)? = nil) {
        var navigationController: UINavigationController? = on as? UINavigationController
        if navigationController == nil { navigationController = on.navigationController }
        navigationController?.pushViewController(base, animated: animated)
        if (fulfill != nil) { base.fulfill = fulfill }
        if (reject != nil) { base.reject = reject }
    }
    
    // ReusePromiseable 을 Promiseable 처럼 1회용으로 사용할 수 있는 인터페이스
    func promiseablePresented(on: UIViewController, animated: Bool = true, withNavigationController: Bool = false) -> Promise<Base.PromiseData> {
        return Promise<Base.PromiseData> { fulfill, reject in
            self.presented(on: on,
                           animated: animated, withNavigationController: withNavigationController,
                           fulfill: { ticket -> Promise<Void> in
                self.base.dismiss(animated: true) {
                    fulfill(ticket)
                }
                return Promise(())
            }, reject: { error -> Void in
                self.base.dismiss(animated: true) {
                    reject(error)
                }
            })
        }
    }
}

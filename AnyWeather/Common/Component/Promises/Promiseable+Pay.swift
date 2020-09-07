//
//  Promiseable+UIViewController.swift
//  Kakaopay
//
//  Created by henry on 2018. 3. 29..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import UIKit
import Kakaopay
import Promises

extension Pay where Base: (UIViewController & Promiseable) {
    // on 이 UINavigationController 인 경우에는 push 방식으로, 아닌 경우에는 modal 방식으로 present 합니다.
    func presentedOrPushed(on: UIViewController, animated: Bool = true) -> Promise<Base.PromiseData> {
        if on is UINavigationController {
            return pushed(on: on, animated: animated)
        } else {
            return presented(on: on, animated: animated, withNavigationController: true)
        }
    }

    func presented(on: UIViewController, animated: Bool = true, withNavigationController: Bool = false) -> Promise<Base.PromiseData> {
        guard withNavigationController else {
            on.present(base, animated: animated, completion: nil)
            return base.promise
        }
        on.present(UINavigationController(rootViewController: base), animated: animated, completion: nil)
        return base.promise
    }
    
    fileprivate func dismiss(animated: Bool, completion: (() -> Swift.Void)? = nil) {
        base.dismiss(animated: animated) {
            completion?()
        }
    }
    
    func pushed(on: UIViewController, animated: Bool = true) -> Promise<Base.PromiseData> {
        var navigationController: UINavigationController? = on as? UINavigationController
        if navigationController == nil { navigationController = on.navigationController }
        navigationController?.pushViewController(base, animated: animated)
        return base.promise
    }
    
    fileprivate func pop(animated: Bool, completion: (() -> Swift.Void)? = nil) {
        base.navigationController?.popViewController(animated: animated)
        completion?()
    }

    func fulfill(data: Base.PromiseData, animated: Bool = true, presented: Bool = true, completion: (() -> Swift.Void)? = nil) {
        if (presented) {
            dismiss(animated: animated) {
                self.base.promise.fulfill(data)
                completion?()
            }
        } else {
            pop(animated: animated) {
                self.base.promise.fulfill(data)
            }
        }
    }
    
    func reject(error: Error, animated: Bool = true, presented: Bool = true, completion: (() -> Swift.Void)? = nil) {
        if (presented) {
            dismiss(animated: animated) {
                self.base.promise.reject(error)
                completion?()
            }
        } else {
            pop(animated: animated) {
                self.base.promise.reject(error)
            }
        }
    }
}

extension Pay where Base: (UIViewController & Promiseable), Base.PromiseData == Void {
    func fulfill(animated: Bool, presented:Bool = true, completion: (() -> Swift.Void)? = nil) {
        if (presented) {
            dismiss(animated: animated) {
                self.base.promise.fulfill(())
                completion?()
            }
        } else {
            pop(animated: animated) {
                self.base.promise.fulfill(())
            }
        }
    }
}

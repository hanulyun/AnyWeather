//
//  UIViewController+Promises.swift
//  Kakaopay
//
//  Created by henry on 2018. 3. 12..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import UIKit
import Promises

protocol Promiseable: class {
    associatedtype PromiseData
    var promise: Promise<PromiseData> { get set }
}

private var promiseAssociatedObjectKey: Void?
extension Promiseable {
    
    public var promise: Promise<PromiseData> {
        get {
            var promises = objc_getAssociatedObject(self, &promiseAssociatedObjectKey) as? Promise<PromiseData>
            if promises == nil {
                promises = Promise<PromiseData>.pending()
                objc_setAssociatedObject(self, &promiseAssociatedObjectKey, promises, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            return promises!
        }
        set {
            objc_setAssociatedObject(self, &promiseAssociatedObjectKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

extension Promise {
    
    func then<Result>(_ rhs: Promise<Result>) -> Promise<Result> {
        return then { value -> Promise<Result> in
            return rhs
        }
    }
}

extension Promise where Value == Void {

    @discardableResult
    static func start<Result>(on queue: DispatchQueue = .promises, _ work: @escaping () throws -> Promise<Result>) -> Promise<Result> {
        return Promise<Void>{}.then(work)
    }

    @discardableResult
    static func start<Result>(on queue: DispatchQueue = .promises, _ work: @escaping () throws -> Result) -> Promise<Result> {
        return Promise<Void>{}.then(work)
    }

    @discardableResult
    static func start(on queue: DispatchQueue = .promises, _ work: @escaping () throws -> Void) -> Promise<Void> {
        return Promise<Void>{}.then(work)
    }
    
    static var start: Promise<Void> {
        return Promise<Void> {}
    }
}

extension Promise {

    func validate(on queue: DispatchQueue = .promises, _ isValidated: Bool) -> Promise {
        return validate(on: queue) { value -> Bool in
            return isValidated
        }
    }
}

extension Promise {
    
    @discardableResult
    public func `catch`<ErrorType: Error>(on queue: DispatchQueue = .promises, _ reject: @escaping (ErrorType) -> Void) -> Promise {
        return self.catch(on: queue) { (error) -> Void in
            guard let typedError = error as? ErrorType else {
                return
            }
            reject(typedError)
        }
    }
}

precedencegroup PromisePrecedence {
    associativity: left
}

/*
 > then
 < always
 ! catch
 ? validate
 !> recover
 */
infix operator +> : PromisePrecedence // then
infix operator +< : PromisePrecedence // always
infix operator +! : PromisePrecedence // catch
infix operator +? : PromisePrecedence // validate
infix operator +!> : PromisePrecedence // recover

extension Promise {
    
    @discardableResult
    static func +><Result>(lhs: Promise, rhs: Promise<Result>) -> Promise<Result> {
        return lhs.then(rhs)
    }
    
    @discardableResult
    static func +><Result>(promise: Promise, _ work: @escaping (Value) throws -> Promise<Result>) -> Promise<Result> {
        return promise.then(work)
    }

    @discardableResult
    static func +><Result>(promise: Promise, _ work: @escaping (Value) throws -> Result) -> Promise<Result> {
        return promise.then(work)
    }
    
    @discardableResult
    static func +>(promise: Promise, _ work: @escaping (Value) throws -> Void) -> Promise {
        return promise.then(work)
    }

    @discardableResult
    static func +<(promise: Promise, _ work: @escaping () -> Void) -> Promise {
        return promise.always(work)
    }

    @discardableResult
    static func +!(promise: Promise, _ reject: @escaping Catch) -> Promise {
        return promise.catch(reject)
    }

    @discardableResult
    static func +!<ErrorType: Error>(promise: Promise, _ reject: @escaping (ErrorType) -> Void) -> Promise {
        return promise.catch(reject)
    }
    
    @discardableResult
    static func +?(promise: Promise, _ predicate: @escaping (Value) -> Bool) -> Promise {
        return promise.validate(predicate)
    }
    
    @discardableResult
    static func +!>(promise: Promise, _ recovery: @escaping (Error) throws -> Promise<Value>) -> Promise {
        return promise.recover(recovery)
    }
}



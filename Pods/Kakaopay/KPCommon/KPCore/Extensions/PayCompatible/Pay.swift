//
//  Pay.swift
//  Kakaopay
//
//  Created by Freddy on 2018. 5. 2..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import Foundation

// Namespace - pay
// Referenced by Kingfisher, RxSwift
// http://minsone.github.io/programming/swift4-grouping-with-protocol-extension
// https://github.com/onevcat/Kingfisher/blob/master/Sources/Kingfisher.swift
// https://github.com/ReactiveX/RxSwift/blob/master/RxSwift/Reactive.swift

public final class Pay<Base> {
    /// Base object to extend.
    public let base: Base

    /// Creates extensions with base object.
    ///
    /// - parameter base: Base object.
    public init(_ base: Base) {
        self.base = base
    }
}

/// A type that has pay extensions.
public protocol PayCompatible {
    /// Extended type
    associatedtype CompatibleType

    static var pay: Pay<CompatibleType>.Type { get set }
    
    var pay: Pay<CompatibleType> { get set }
}

public extension PayCompatible {
    /// Pay extensions.
    static var pay: Pay<Self>.Type {
        get {
            return Pay<Self>.self
        }
        set {
            // this enables using Pay to "mutate" base type
        }
    }
    
    /// Pay extensions.
    var pay: Pay<Self> {
        get {
            return Pay(self)
        }
        set {
            // this enables using Pay to "mutate" base object
        }
    }
}

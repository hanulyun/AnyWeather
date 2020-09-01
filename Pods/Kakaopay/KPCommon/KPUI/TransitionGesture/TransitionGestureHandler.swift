//
//  TransitionGestureHandler.swift
//  KPCommon
//
//  Created by kali_company on 22/02/2019.
//  Copyright © 2019 kakaopay. All rights reserved.
//

import Foundation

public protocol TransitionGestureHandler {
    var transitioningHandler: TransitioningHandler? { get set }
    var didStartGesture: ((TransitionGestureHandler) -> ())? { get set }
    var didFinishGesture: ((TransitionGestureHandler) -> ())? { get set }
    var shouldStartGesture: ((TransitionGestureHandler) -> Bool)? { get set }
    var isInteractive: Bool { get set }
    var isCanceled: Bool { get set }
}

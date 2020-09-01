//
//  InteractiveAnimator.swift
//  KPCommon
//
//  Created by kali_company on 25/02/2019.
//  Copyright © 2019 kakaopay. All rights reserved.
//

import Foundation

public protocol InteractiveAnimator {
    func startInterativeAnimation(context: UIViewControllerContextTransitioning)
}

extension InteractiveAnimator {
    public func startInterativeAnimation(context: UIViewControllerContextTransitioning) {}
}

//
//  OverlayManager.swift
//  KPUI
//
//  Created by henry on 2018. 2. 19..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import UIKit

public class OverlayManager {
    public static let shared: OverlayManager = OverlayManager()
    fileprivate static var overlayWindows: Set<OverlayWindow> = []

    public init() {}
    
    internal func regist(window: OverlayWindow) {
        // regist window
        if !OverlayManager.overlayWindows.contains(window) {
            window.backgroundColor = UIColor.clear
            window.isHidden = false
            window.rootViewController = OverlayWindowViewController()
        }
        OverlayManager.overlayWindows.update(with: window)
    }
    
    internal func unregist(window: OverlayWindow) {
        // unregist manager
        OverlayManager.overlayWindows.remove(window)
    }
    
    public func unregistAll() {
        OverlayManager.overlayWindows.removeAll()
    }
}

public extension UIApplication {
    
    internal var overlayWindows: Set<OverlayWindow> {
        return OverlayManager.overlayWindows
    }
}

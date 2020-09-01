//
//  OverlayWindow.swift
//  KPUI
//
//  Created by henry on 2018. 2. 12..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import UIKit


/*
 key window 에 이벤트 전달을 위한 OverlayWindow
 https://github.kakaocorp.com/kakaopay-client/ios-pay-app/issues/19
 */
public let WindowLevelOverlay = UIWindow.Level.alert - 1   // level between alert and statusbar
open class Overlay {
    
    private weak var overlayWindow: OverlayWindow? = nil
    public var overlayViewController: OverlayWindowViewController? {
        return overlayWindow?.rootViewController as? OverlayWindowViewController
    }
    
    public init() {}
    
    public var windowLevel: UIWindow.Level {
        get {
            if let overlayWindow = self.overlayWindow {
                return overlayWindow.windowLevel
            }
            return UIWindow.Level(rawValue: 0.0)
        }
        set {
            if let overlayWindow = self.overlayWindow {
                overlayWindow.windowLevel = newValue
            }
        }
    }
    
    public var isVisible: Bool {
        get {
            if let overlayWindow = self.overlayWindow {
                return !overlayWindow.isHidden
            }
            return false
        }
        set {
            if newValue {
                if overlayWindow == nil {
                    let newWindow = OverlayWindow()
                    newWindow.windowLevel = WindowLevelOverlay
                    newWindow.isHidden = false
                    OverlayManager.shared.regist(window: newWindow)
                    overlayWindow = newWindow
                }
            } else {
                if let overlayWindow = self.overlayWindow {
                    OverlayManager.shared.unregist(window: overlayWindow)
                }
            }
        }
    }
}

class OverlayWindow: UIWindow {
    public var overlayViewController: OverlayWindowViewController {
        return rootViewController as! OverlayWindowViewController
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        return (hitView == self) ? nil : hitView
    }
}
public class OverlayWindowViewController: OverlayContainerViewController {}


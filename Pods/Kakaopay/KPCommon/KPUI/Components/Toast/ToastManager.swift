//
//  ToastManager.swift
//  KPUI
//
//  Created by henry on 2018. 2. 12..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import UIKit

public enum ToastDelay: TimeInterval {
    case long = 5
    case short = 2
}

public protocol ToastPresentable {
    static func instantiate(message: String) -> (UIViewController & ToastPresentable)?
    func updateMessage(message: String)
}

public class ToastManager: Overlay {
    typealias ToastData = (viewController: UIViewController & ToastPresentable, duration: TimeInterval)
    
    public static let shared: ToastManager = ToastManager()
    
    private var timer: Timer?
    private var currentToastData: ToastData?
    private var toastDataQueue = Array<ToastData>()
    
    @discardableResult
    public func present(message: String, type: (ToastPresentable).Type = ToastViewController.self, delay: ToastDelay = .short) -> (UIViewController & ToastPresentable)? {
        
        guard let toastController = type.instantiate(message: message) else {
            return nil
        }
        
        present(toast: toastController, delay: delay)
        return toastController
    }
    
    @discardableResult
    public func presentWithoutQueue(message: String, type: (ToastPresentable).Type = ToastViewController.self, delay: ToastDelay = .short) -> (UIViewController & ToastPresentable)? {
        
        if let currentToast = currentToastData?.viewController {
            currentToast.updateMessage(message: message)
            self.timer?.invalidate()
            self.timer = Timer.scheduledTimer(withTimeInterval: currentToastData!.duration, repeats: false) { timer in
                self.dismissCurrent()
            }
            return currentToast
        }
        return present(message:message, type:type, delay:delay)
        
    }
    

    public func present(toast: (UIViewController & ToastPresentable), delay: ToastDelay = .short) {
        
        let toastData = ToastData(viewController: toast, duration: delay.rawValue)
        toastDataQueue.append(toastData)
        
        if currentToastData == nil {
            presentNext()
        }
    }

    private func presentNext() {
        self.isVisible = !self.toastDataQueue.isEmpty
        
        if self.toastDataQueue.isEmpty == false {
            let toastData = self.toastDataQueue.removeFirst()
            
            if let animatableViewController = toastData.viewController as? UIViewController & TransitionAnimatable {
                self.overlayViewController?.add(content: animatableViewController, animated: true)
            } else {
                self.overlayViewController?.add(content: toastData.viewController)
            }
            
            self.currentToastData = toastData;
            self.timer = Timer.scheduledTimer(withTimeInterval: toastData.duration, repeats: false) { timer in
                self.dismissCurrent()
            }
        }
    }
    
    private func dismissCurrent() {
        guard let currentToast = currentToastData?.viewController else {
            return
        }
        
        if let animatableViewController = currentToast as? UIViewController & TransitionAnimatable {
            self.overlayViewController?.remove(content: animatableViewController, animated: true) { didComplete in
                self.currentToastData = nil
                self.presentNext()
            }
        } else {
            self.overlayViewController?.remove(content: currentToast)
            self.currentToastData = nil
            self.presentNext()
        }
    }
}


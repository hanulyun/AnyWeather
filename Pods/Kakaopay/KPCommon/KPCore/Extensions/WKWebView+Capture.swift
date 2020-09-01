//
//  WKWebView+Capture.swift
//  Kakaopay
//
//  Created by Lyman.j on 26/06/2019.
//

import Foundation
import WebKit

extension Pay where Base == WKWebView {
    public func screenCapture(callback: @escaping (UIImage?)-> ()) {
        base.screenCapture(callback: callback)
    }
}


extension WKWebView {
    
    @objc public func screenCapture(callback: @escaping (UIImage?)-> () ) {
        
        let rect = CGRect(x: 0, y: 0, width: self.scrollView.contentSize.width, height: self.scrollView.contentSize.height)
        let originFrame = self.frame
        let layer = self.layer
        layer.frame = rect
        let scale = UIScreen.main.scale
        
        //보이지 않는 부분까지 draw를 위한 delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
            layer.render(in: UIGraphicsGetCurrentContext()!)
            let screenshot = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            layer.frame = originFrame
            callback(screenshot)
        }
    }
}



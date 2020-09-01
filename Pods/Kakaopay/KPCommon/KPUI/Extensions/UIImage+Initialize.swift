//
//  UIImage+Initialize.swift
//  KPUI
//
//  Created by henry on 2018. 2. 6..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import UIKit

extension Pay where Base: UIImage {
    public static func create(view: UIView) -> UIImage? {
        return UIImage(view: view)
    }

    public static func create(color: UIColor, size: CGSize = CGSize(width: 2, height: 2)) -> UIImage? {
        guard #available(iOS 13.0, *) else {
            return UIImage(color: color, size: size)
        }
        
        let defaultImage = UIImage(color: color.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light)), size: size)
        if let darkImage = UIImage(color: color.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark)), size: size) {
            defaultImage?.imageAsset?.register(darkImage, with: UITraitCollection(userInterfaceStyle: .dark))
        }
        
        return defaultImage
    }
    
    public static func create(hex: String, alpha: CGFloat = 1.0, size: CGSize = CGSize(width: 2, height: 2)) -> UIImage? {
        return create(color: UIColor(hex: hex, alpha: alpha), size: size)
    }
}

// MARK: - init with UIView
extension UIImage {
    
    internal convenience init?(view: UIView) {
        
        let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
        let image = renderer.image { ctx in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }

        guard let cgImage = image.cgImage else {
            return nil
        }
        self.init(cgImage: cgImage)
    }
}

// MARK: - init with UIColor
extension UIImage {
    
    internal convenience init?(color: UIColor, size: CGSize = CGSize(width: 2, height: 2)) {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer { UIGraphicsEndImageContext() }
        
        color.setFill()
        UIRectFill(CGRect(origin: CGPoint.zero, size: size))
        
        guard let cgImage = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else {
            return nil
        }
        self.init(cgImage: cgImage)
    }
}

// MARK: - init with Hex String
extension UIImage {
    
    internal convenience init?(hex: String, alpha: CGFloat = 1.0, size: CGSize = CGSize(width: 2, height: 2)) {
        self.init(color: UIColor(hex: hex, alpha: alpha), size: size)
    }
}

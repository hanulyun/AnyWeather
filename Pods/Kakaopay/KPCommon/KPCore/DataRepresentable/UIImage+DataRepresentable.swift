//
//  UIImage+DataRepresentable.swift
//  KPCore
//
//  Created by henry on 2018. 3. 2..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import UIKit

extension UIImage: DataRepresentable {
    
    public func toData() -> Data? {
        return self.pngData()
    }
    
    public static func fromData<ReturnType>(_ data: Data) -> ReturnType? {
        return UIImage(data: data, scale: UIScreen.main.scale) as? ReturnType
    }
}


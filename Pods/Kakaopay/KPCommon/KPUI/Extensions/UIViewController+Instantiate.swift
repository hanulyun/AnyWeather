//
//  Instantiate.swift
//  KPUI
//
//  Created by henry on 2018. 2. 2..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import UIKit

extension UIViewController {

    public static func instantiate<ClassType: UIViewController>(storyboardName: String?, identifier: String? = nil) -> ClassType? {
        let name = storyboardName ?? String(describing: self)
        
        if identifier == nil {
            return UIStoryboard(name: name, bundle: Bundle(for: self)).instantiateInitialViewController() as? ClassType
        }
        return UIStoryboard(name: name, bundle: Bundle(for: self)).instantiateViewController(withIdentifier: identifier!) as? ClassType
    }
}

extension UIView {

    public static func instantiate<ClassType: UIView>(nibName: String? = nil) -> ClassType? {
        let name = nibName ?? String(describing: self)
        return UINib(nibName: name, bundle: Bundle(for: self)).instantiate(withOwner: self, options: nil)[0] as? ClassType
    }
}

//
//  UITableView+Extensions.swift
//  KPUI
//
//  Created by Freddy on 2018. 7. 5..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import Foundation

extension Pay where Base: UITableView {
    public func reloadData(_ completion: @escaping () -> Void) {
        base.reloadData(completion)
    }
}

extension UITableView {
    
    /// Reload data with a completion handler.
    ///
    /// - Parameter completion: completion handler to run after reloadData finishes.
    internal func reloadData(_ completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0, animations: {
            self.reloadData()
        }, completion: { _ in
            completion()
        })
    }
}

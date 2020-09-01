//
//  TouchDisableView.swift
//  KPUI
//
//  Created by henry on 2018. 2. 13..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import UIKit

public class TouchDisableView: UIView {
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        return (hitView == self) ? nil : hitView
    }
}

public class TouchDisableTableView: UITableView {
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        return (hitView == self) ? nil : hitView
    }
}

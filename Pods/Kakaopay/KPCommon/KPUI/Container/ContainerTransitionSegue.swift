//
//  AnimatedTransitionSegue.swift
//  KPUI
//
//  Created by henry on 2018. 3. 26..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import UIKit

class ContainerTransitionSegue: UIStoryboardSegue {
    
    private var isUnwind: Bool {
        return self.source.parent == self.destination
    }
    
    override func perform() {
        guard let from = (isUnwind ? self.destination : self.source) as? (UIViewController & ContainerViewController) else {
            print("[ContainerTransitionSegue::perform] Error reason : source view controller must conform a ContainerViewController protocol")
            return
        }
        
        let to = (isUnwind ? self.source : self.destination)
        let containerView = from.containerView(for: identifier)
        
        if !isUnwind {
            // add
            if let animatable = to as? (UIViewController & TransitionAnimatable) {
                from.add(content: animatable, on: containerView, animated: true)
            } else {
                from.add(content: to, on: containerView)
            }
        } else {
            // remove
            if let animatable = to as? (UIViewController & TransitionAnimatable) {
                from.remove(content: animatable, animated: true)
            } else {
                from.remove(content: to)
            }
        }
    }
}

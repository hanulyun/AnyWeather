//
//  AnimatedStoryboardSegue.swift
//  KPUI
//
//  Created by henry on 2018. 3. 26..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import UIKit

class AnimatedTransitionSegue: UIStoryboardSegue {
    
    override func perform() {
        
        if let animatable = destination as? TransitionAnimatable {
            animatable.transitioningHandler.isEnabled = true
        }
        super.perform()
    }
}


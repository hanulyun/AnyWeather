//
//  GroupPropertyAnimator.swift
//  AloeStackView
//
//  Created by henry on 05/07/2019.
//

import UIKit

/*
 복수개의 animator 가 동시에(spawn) 실행되는 animation 을 만들고자 할때 사용합니다.
 SqawnPropertyAnimator 자체의 animation 기능은(start/stop) 동작하지 않으며, 전체 길이는 제공받은 animator 중에 가장 긴 duration 으로 선택됩니다.
 
 다음과 같이 사용 가능합니다.
 SqawnPropertyAnimator([FadePropertyAnimator, RevealPropertyAnimator])
 */
final public class GroupPropertyAnimator: UIViewPropertyAnimator {
    
    private var propertyAnimators = [UIViewPropertyAnimator]()
    private weak var representedAnimator: UIViewPropertyAnimator! // max duration animator.
    
    convenience public init(_ propertyAnimators: [UIViewPropertyAnimator]) {
        let representedAnimator = propertyAnimators.max { (lhs, rhs) -> Bool in
            return lhs.duration < rhs.duration
        }
        self.init(duration: representedAnimator?.duration ?? 0.3, curve: .linear) {}
        self.propertyAnimators = propertyAnimators
    }
    
    public override func startAnimation() {
        super.startAnimation()
        propertyAnimators.forEach { (animator) in
            animator.startAnimation()
        }
    }
    
    public override func stopAnimation(_ withoutFinishing: Bool) {
        super.stopAnimation(withoutFinishing)
        propertyAnimators.forEach { (animator) in
            animator.stopAnimation(withoutFinishing)
        }
    }
}


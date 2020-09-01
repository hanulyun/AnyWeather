//
//  SkeletonLayer.swift
//  AloeStackView
//
//  Created by henry.my on 2020/08/18.
//

import Foundation

class SkeletonLayer: CAGradientLayer {
    
    private static let skeletonAnimationKey = "com.kakaopay.common.skeletonAnimationKey"
    private weak var skeleton: SkeletonView!
    
    var isAnimating: Bool {
        return (animation(forKey: SkeletonLayer.skeletonAnimationKey) != nil)
    }

    func start(_ skeleton: SkeletonView) {
        self.skeleton = skeleton
        stop()
        
        var skeletonColor = skeleton.color ?? SkeletonView.defaultColor
        if #available(iOS 13.0, *) {
            skeletonColor = skeletonColor.resolvedColor(with: skeleton.traitCollection)
        } else { // 12 이하에서는 color asset 을 통한 값이 정상적으로 나오지 않아서 재생성.
            skeletonColor = UIColor.pay.hex(skeletonColor.pay.hexString)
        }
        setGradientCGColors(from: skeletonColor, isDarkMode: skeleton.isDarkMode)
        setAutoRound(skeleton.autoRounded)
        
        switch skeleton.type {
        case .single:
            startSingle()
        case .fade:
            startFade(skeletonColor)
        }
    }
    
    private func startSingle() {
        let size = frame.size
        // 200pt 기준으로 적절한 x값
        let widthScale = (200.0 / size.width)
        // 20pt 기준으로 적절한 y값
        let heightScale = pow(widthScale, 2) * (size.height / 20.0)

        // 자연스러운 gradient width 를 위하여 적잘한 factor 계산
        var maxFactor: CGFloat = 1.5
        var minFactor: CGFloat = 1.0
        var heightFactor: CGFloat = -0.03
        var animDuration: CFTimeInterval = skeleton.duration
        var animDelay: CFTimeInterval = skeleton.delay
        
        // 기준값이 넘는 크기는 좀 더 좁게 보여줄 필요가 있음
        if size.width > 300.0 {
            maxFactor = 2.0
            minFactor = 1.6
            heightFactor = -0.025
        }
        
        // 속도 변수들이 기본 세팅값 (.auto) 일 경우 적절하게 할당
        if animDuration < 0.0 { // .auto
            animDuration = 1.0
        }
        if animDelay < 0.0 { // .auto
            if animDuration < 1.0 {
                animDelay = 1.0 - animDuration
            } else { animDelay = 0.0 }
        }
        
        let startPointAnim = CABasicAnimation(keyPath: #keyPath(startPoint))
        startPointAnim.fromValue = NSValue(cgPoint: CGPoint(x: 0.5 - (widthScale * maxFactor), y: heightScale * heightFactor))
        startPointAnim.toValue = NSValue(cgPoint: CGPoint(x: 0.5 + (widthScale * minFactor), y: heightScale * heightFactor))
        startPointAnim.duration = animDuration
        startPointAnim.fillMode = .forwards

        let endPointAnim = CABasicAnimation(keyPath: #keyPath(endPoint))
        endPointAnim.fromValue = NSValue(cgPoint: CGPoint(x: 0.5 - (widthScale * minFactor), y: 0.0))
        endPointAnim.toValue = NSValue(cgPoint: CGPoint(x: 0.5 + (widthScale * maxFactor), y: 0.0))
        endPointAnim.duration = animDuration
        endPointAnim.fillMode = .forwards
        
        let animGroup = CAAnimationGroup()
        animGroup.animations = [startPointAnim, endPointAnim]
        animGroup.duration = animDuration + animDelay
        animGroup.timingFunction = CAMediaTimingFunction(name: skeleton.timingFunction)
        animGroup.repeatCount = .infinity
        
        add(animGroup, forKey: SkeletonLayer.skeletonAnimationKey)
    }
    
    private func startFade(_ color: UIColor) {
        let fromColor = color.cgColor
        let adjustedTotalFactor: CGFloat = skeleton.isDarkMode ? 1.3 : 1.05
        let toColor = color.adjust(by: adjustedTotalFactor).cgColor
        
        var animDuration: CFTimeInterval = skeleton.duration
        var animDelay: CFTimeInterval = skeleton.delay
        if animDuration < 0.0 { // .auto
            animDuration = 1.0
        }
        if animDelay < 0.0 { // .auto
            if animDuration < 1.0 {
                animDelay = 1.0 - animDuration
            } else { animDelay = 0.0 }
        }
        
        startPoint = CGPoint(x: 0, y: 0)
        endPoint = CGPoint(x: 1, y: 1)
        colors = [fromColor, fromColor]
        
        let animation: CABasicAnimation = CABasicAnimation(keyPath: #keyPath(colors))
        animation.fromValue = [fromColor, fromColor] // gradient 의 가장 어두운 값과
        animation.toValue = [toColor, toColor] // 가장 밝은 값으로 선택
        animation.fillMode = .forwards
        animation.duration = animDuration
        
        let animGroup = CAAnimationGroup()
        animGroup.animations = [animation]
        animGroup.duration = animDuration + animDelay
        animGroup.timingFunction = CAMediaTimingFunction(name: skeleton.timingFunction)
        animGroup.repeatCount = .infinity
        animGroup.autoreverses = true

        add(animGroup, forKey: SkeletonLayer.skeletonAnimationKey)
    }
    
    func stop() {
        removeAnimation(forKey: SkeletonLayer.skeletonAnimationKey)
    }
    
    private func setGradientCGColors(from color: UIColor, isDarkMode: Bool) {
        let emptiedLevel: Int = 0 /* gradient 의 밀도를 조절 */
        let level: Int = 3 /* 로띠 버전과 최대한 비슷한 값 */
        let sign: CGFloat = 1.0
        let adjustedTotalFactor: CGFloat = isDarkMode ? 0.3 : 0.045
        let adjustedFactor = adjustedTotalFactor / CGFloat(level)
        
        // level 에 따른 color 변화값 (gradient effect)
        var i: Int = 0
        var leveledFactors: [CGFloat] = .init(repeating: 1.0, count: emptiedLevel)
        while i <= level {
            let leveledFactor: CGFloat = (sign * (CGFloat(i) * adjustedFactor))
            leveledFactors.append(1.00 + leveledFactor)
            i += 1
        }
        leveledFactors.dropLast().sorted(by: >).forEach { leveledFactors.append($0) }
        colors = leveledFactors.map { color.adjust(by: $0).cgColor }
    }

    private func setAutoRound(_ autoRounded: Bool) {
        guard autoRounded == true else {
            cornerRadius = 0.0
            return
        }
        
        if skeleton.layer.cornerRadius > 0.0 {
            cornerRadius = skeleton.layer.cornerRadius
        } else if let originalView = skeleton.originalView, originalView.layer.cornerRadius > 0.0 {
            cornerRadius = originalView.layer.cornerRadius
        } else {
            cornerRadius = bounds.height / 2.0
        }
    }
    
    func layoutDidChange() {
        if isAnimating, skeleton != nil {
            start(skeleton)
        }
    }
}

extension UIColor {
    fileprivate func adjust(by factor: CGFloat) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return UIColor(hue: h, saturation: s, brightness: b * factor, alpha: a)
    }
}

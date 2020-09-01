//
//  SkeletonView.swift
//  PayApp
//
//  Created by henry.my on 2020/07/30.
//  Copyright © 2020 kakaopay. All rights reserved.
//

import Foundation

/*
 다음과 같이 skeleton animation 시작과 정지 가능
 -> view.skeleton.start()
 -> view.skeleton.stop()
 
 skeleton 배경 color 값 지정 (dark theme 이 포함된 ColorSet 가능)
 1. 앱에 전반적으로 적용되는 기본 color 값을 설정하거나,
 -> SkeletonView.defaultColor = UIColor.pay.gray200 // 모든 skeleton 기본 컬러셋
 2. start() 함수의 파라메터로 특정 skeleton 의 배경색 color 만 따로 지정할 수 있음
 -> view.skeleton.start(UIColor.pay.gray200)
 
 skeleton type 옵션 (SkeletonType)
 1. 현재는 single(rounded: Bool = t`rue) 옵션만 지원함. rounded 는 좌우를 둥글게 표현할 것인지 여부이며 SquirecleView 같은 커스텀 shape 의 View 에 사용하려면 false 로 지정 필요. (예제 참고)
 2. 추후 다른 type 으로 표현해야 하는 경우가 있다면 요 Type 값을 확장할 계획
 */
private var SkeletonViewAssociatedObjectKey: Void?
extension UIView {

    public var skeleton: SkeletonView! {
        get {
            guard (self is SkeletonView) == false else { return SkeletonView() } // simpliy ignored
            if let skeletonView = objc_getAssociatedObject(self, &SkeletonViewAssociatedObjectKey) as? SkeletonView {
                return skeletonView
            }
            let skeletonView = SkeletonView()
            skeletonView.originalView = self
            objc_setAssociatedObject(self, &SkeletonViewAssociatedObjectKey, skeletonView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return skeletonView
        }
    }
}

public enum SkeletonType {
    case fade // 숨쉬는 듯한 fade animation
    case single // 한줄 gradient animation
    
//    case multiline // TODO: TextView 와 같이 멀티 라인이 필요한 니즈가 있다면 확장하여 구현
}
    
extension CFTimeInterval {
    public static let auto: CFTimeInterval = -1
}

public class SkeletonView: UIView {

    public static var defaultColor: UIColor = .lightGray

    /*
     color 설정 (default: nil)
     -> 별도로 설정하지 않은 경우 전역 컬러 값 SkeletonView.defaultColor = color 에 할당된 값으로 적용 됩니다.
     -> 매번 color 를 지정해야 하므로 view 마다 다르게 보일 필요가 있을때만 해당 프로퍼티를 설정해 주세요.
     -> dark theme color 도 자동 적용 됩니다.
     */
    public var color: UIColor? = nil
    /*
     type 설정 (default: .single)
     -> .single: 기존 로띠 버전의 skeleton 과 유사한 모양을 하는 animation 입니다.
     -> .fade: gradient animation 없이 숨쉬는 듯한 fade 효과를 주는 animation 입니다.
     */
    public var type: SkeletonType = .single
    /*
     animation duration 설정 (default: .auto)
     -> delay 가 .auto 로 설정되어 있을 경우 duration 값에 따라 자동적으로 변경됩니다.
     -> 1.0 이상의 값도 사용 가능하나 부자연스러워 보이므로 비추합니다.
     */
    public var duration: CFTimeInterval = .auto // auto 일 경우 기본값 1.0
    public var delay: CFTimeInterval = .auto // auto 일 경우 duration 값에 따라 자동 조절 됩니다.
    /*
     autoRounded 옵션 (default: true)
     -> false 로 되어 있을시 round 처리를 전혀 진행하지 않습니다. (SquirecleView 처럼 mask 형태일 경우 선택)
     -> true 로 되어 있을 경우.
        1. SkeletonView 에 직접 corner radius 를 주는 경우 그대로 적용 됨 (원래 View 와 스켈레톤 View 의 radius 값이 달라야 할때)
        2. 원래 View 에 corner radius 가 있는 경우 그대로 적용 됨 (원래 View 에 명시적인 corner radius 값이 있을 때)
        3. 1, 2번 모두 해당되지 않는 경우 height / 2 값으로 자동 round 처리 됨 (UILabel, UITextView 처럼 corner radius 를 명시적으로 주지 않을 때)
     */
    public var autoRounded: Bool = true
    public var timingFunction: CAMediaTimingFunctionName = .easeIn
    
    weak var originalView: UIView?
    fileprivate func setupIfPossible() {
        guard self.superview == nil, (originalView is SkeletonView) == false else {
            return
        }
        if let superView = originalView?.superview {
            superView.addSubview(self)
            translatesAutoresizingMaskIntoConstraints = false
            pay.fillAnchor.constraints(equalTo: originalView!.pay.fillAnchor).isActive = true
            frame = originalView!.frame
            backgroundColor = originalView!.backgroundColor
        }
    }
        
    public var isAnimating: Bool {
        return skeletonLayer.isAnimating
    }
    
    var isDarkMode: Bool {
        if #available(iOS 12.0, *) {
            return (traitCollection.userInterfaceStyle == .dark)
        }
        return false
    }
    
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 13.0, *), traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            skeletonLayer.layoutDidChange()
        }
    }

    private var _isStarting: Bool = false
    public func start(type maybeType: SkeletonType? = nil) {
        guard (originalView is SkeletonView) == false else { return }
        if let type = maybeType { self.type = type }
        setupIfPossible()
        skeletonLayer.start(self)
        originalView?.isHidden = true
        isHidden = false
    }
    
    public func stop() {
        guard (originalView is SkeletonView) == false else { return }
        skeletonLayer.stop()
        originalView?.isHidden = false
        isHidden = true
    }
    
    override open class var layerClass: AnyClass {
        return SkeletonLayer.self
    }
    
    private var skeletonLayer: SkeletonLayer {
        return (layer as! SkeletonLayer)
    }

    private var priviousFrame: CGRect?
    override public func layoutSubviews() {
        super.layoutSubviews()
        if priviousFrame != frame {
            skeletonLayer.layoutDidChange()
            priviousFrame = frame
        }
    }
}

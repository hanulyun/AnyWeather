//
//  PayBottomView.swift
//  PayApp
//
//  Created by henry on 30/01/2019.
//  Copyright © 2019 kakaopay. All rights reserved.
//

import UIKit

/*
 Required
 화면 하단에서 높이가 변화하는 BottomSheet 형식의 View 를 정의합니다.
 */
public protocol BottomViewAnimatable: TransitionAnimatable {
    var bottomView: UIView! { get set } // bottomView
    var bottomViewHeightConstraint: NSLayoutConstraint! { get set } // bottomView 의 높이. translate effect
    
    // optional: default height 를 지정할 수 있습니다. 지정하지 않는 경우 bottomViewHeightConstraint 의 값을 따라값니다.
    var bottomViewDefaultHeight: CGFloat! { get set } // bottomView 의 기본 높이값.
    
    // optional: Animation block 안에서 실행되며 추가적인 행동을 정의할 수 있습니다.
    func bottomViewAdditionalAnimations(state: TransitionState?, key: UITransitionContextViewControllerKey)
    
    // optional: dimmedView 가 있을 경우에는 지정할 수 있습니다.
    var bottomViewDimmedView: UIView? { get set } //IBOutlet 지정시 옵셔널 타입이 정확히 일치해야 합니다.
}

private var _bottomViewDefaultHeightAssociatedObjectKey: Void?
public extension BottomViewAnimatable {
    func bottomViewAdditionalAnimations(state: TransitionState?, key: UITransitionContextViewControllerKey) {}
    var bottomViewDimmedView: UIView? { get { return nil } set {} }
    var bottomViewDefaultHeight: CGFloat! { get { return _bottomViewDefaultHeight ?? BottomViewAutomaticDefaultHeight } set { _bottomViewDefaultHeight = newValue } } // by default. apply automatic adjust height.
    
    var _bottomViewDefaultHeight: CGFloat? {
        set { objc_setAssociatedObject(self, &_bottomViewDefaultHeightAssociatedObjectKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
        get { return objc_getAssociatedObject(self, &_bottomViewDefaultHeightAssociatedObjectKey) as? CGFloat }
    }
}

public extension BottomViewAnimatable where Self: UIViewController {
    func presentTransitionAnimator(context: UIViewControllerContextTransitioning) -> UIViewPropertyAnimator {
        return BottomViewPropertyAnimator(context: context, state: .present)
    }
    
    func dismissTransitionAnimator(context: UIViewControllerContextTransitioning) -> UIViewPropertyAnimator {
        return BottomViewPropertyAnimator(context: context, state: .dismiss)
    }
}

public let BottomViewAutomaticDefaultHeight: CGFloat = -1.0

/*
 from bottomView 에서 to bottomView 로 높이가 조정되며 화면 전환 됩니다.
 presenting(띄우는쪽, 이하 from), presented(띄워지는쪽, 이하 to) 는 BottomViewAnimatable 를 이용하여 animation 될 bottomView 에 대한 속성을 지정해야 합니다.
 
 BottomViewAnimatable 지정 여부에 따라 다음과 같은 3가지 case 로 나뉘어 집니다.
 
 1. from, to 모두 BottomViewAnimatable 를 컨폼하는 경우
  -> BottomView 의 높이 변화와 from, to 간의 alpha 변화가 animation 처리 됨.
 2. to 만 BottomViewAnimatable 를 컨폼한 경우
  -> layer transform animation 으로 처리 됩니다.
  -> 높이 변화가 필요하거나 autolayout 에 의존적인 화면은 forceUseAutolayoutEvenModallyPresented 옵션을 통해 높이가 화면 하단(== 0) 에서 원래 위치로 animation 처리 되도록 선택할 수 있습니다.
 3. from 만 BottomViewAnimatable 를 컨폼한 경우
  -> TransitionAnimatable 의 동작 여부는 to 에 의존적이기 때문에 처리되지 않습니다.
 
 *) 2의 경우 별도의 alpha 변화가 없기 때문에 bottomViewDimmedView 를 지정하거나, optional 로 제공되는 bottomViewAddAnimations(state: key:) 함수를 이용해서 View 들의 alpha 값을 customizing 하는 것을 권장합니다.
 */
open class BottomViewPropertyAnimator: UIViewPropertyAnimator {
    private var forceUseAutolayoutWhenModallyPresented: Bool = false // modal present/dismiss 시에 layer transform animation 이 아닌 autolayout 기반의 animation 을 처리할 것인지 여부
    
    public convenience init(context: UIViewControllerContextTransitioning, state: TransitionState? = nil,
                            duration: TimeInterval = 0.3, curve: UIView.AnimationCurve? = .easeInOut, dampingRatio: CGFloat? = nil, forceUseAutolayoutWhenModallyPresented: Bool = false) {
        self.init(duration: duration, curve: curve, dampingRatio: dampingRatio)
        self.forceUseAutolayoutWhenModallyPresented = forceUseAutolayoutWhenModallyPresented
        onAnimate(context: context, state: state)
    }
    
    open func onAnimate(context: UIViewControllerContextTransitioning, state: TransitionState?) {
        guard let fromContainerViewController = context.viewController(forKey: .from), let toContainerViewController = context.viewController(forKey: .to) else {
            return
        }
        
        let maybeFromViewController = pay.findViewControllerInContainerIfPossible(fromContainerViewController) as? (UIViewController & BottomViewAnimatable)
        let maybeToViewController = pay.findViewControllerInContainerIfPossible(toContainerViewController) as? (UIViewController & BottomViewAnimatable)

        // [Optional] default height 가 automatic 일 경우 설정
        if let toViewController = maybeToViewController, toViewController.bottomViewDefaultHeight == BottomViewAutomaticDefaultHeight {
           toViewController.bottomViewDefaultHeight = toViewController.bottomViewHeightConstraint.constant
        }
        if let fromViewController = maybeFromViewController, fromViewController.bottomViewDefaultHeight == BottomViewAutomaticDefaultHeight {
           fromViewController.bottomViewDefaultHeight = fromViewController.bottomViewHeightConstraint.constant
        }
        
        if let fromViewController = maybeFromViewController, let toViewController = maybeToViewController {
            // 1. from 과 to 모두 BottomViewAnimatable 를 컨펌하는 경우에는 BottomView 의 높이를 자연스럽게 변화시킵니다.
            toViewController.bottomViewHeightConstraint.constant = fromViewController.bottomViewHeightConstraint.constant
            toViewController.view.layoutIfNeeded()
            fromViewController.view.layoutIfNeeded()
            
            addAnimations {
                toViewController.bottomViewHeightConstraint.constant = toViewController.bottomViewDefaultHeight
                fromViewController.bottomViewHeightConstraint.constant = toViewController.bottomViewDefaultHeight
                toViewController.view.layoutIfNeeded()
                fromViewController.view.layoutIfNeeded()
                
                fromViewController.bottomViewAdditionalAnimations(state: state, key: .from)
                toViewController.bottomViewAdditionalAnimations(state: state, key: .to)
            }
            
            // TMI: 여러 animation 방식을 시도해 봤는데, alpha 값의 변화는 띄우는화면(from)은 그대로 두고, 띄워지는화면(to) 만 fade-in 하는것이 가장 자연스럽더군요. (dismiss 시에는 반대로)
            if state == nil || state == .present {
                toContainerViewController.view.alpha = 0.0
                addAnimations {
                    toContainerViewController.view.alpha = 1.0
                }
            } else if state == .dismiss {
                fromContainerViewController.view.alpha = 1.0
                addAnimations {
                    fromContainerViewController.view.alpha = 0.0
                }
            }

            toViewController.bottomView.alpha = 1.0
            addCompletion { (_) in
                fromViewController.bottomView.alpha = 0.0
            }
        } else if forceUseAutolayoutWhenModallyPresented == true {
            // 2. to 만 BottomViewAnimatable 를 컨펌하고 있다면 present 일 경우로, BottomView 를 화면 하단에서 올라오는 효과를 줍니다. (dismiss 시에는 반대로)
            if let toViewController = maybeToViewController {
                toViewController.bottomViewHeightConstraint.constant = 0.0
                toViewController.view.layoutIfNeeded()
                toViewController.bottomViewDimmedView?.alpha = 0.0
                addAnimations {
                    toViewController.bottomViewAdditionalAnimations(state: state, key: .to)
                    toViewController.bottomViewHeightConstraint.constant = toViewController.bottomViewDefaultHeight
                    toViewController.view.layoutIfNeeded()
                    toViewController.bottomViewDimmedView?.alpha = 1.0
                }
            } else if let fromViewController = maybeFromViewController {
                fromContainerViewController.view.alpha = 1.0
                fromViewController.bottomView.alpha = 1.0
                addAnimations {
                    fromViewController.bottomViewAdditionalAnimations(state: state, key: .from)
                    fromViewController.bottomViewHeightConstraint.constant = 0.0
                    fromViewController.view.layoutIfNeeded()
                    fromViewController.bottomViewDimmedView?.alpha = 0.0
                }
            }
        } else {
            //2. to 만 BottomViewAnimatable 를 컨펌하고 있다면 present 일 경우로, BottomView 를 화면 하단에서 올라오는 효과를 줍니다. (dismiss 시에는 반대로)
            if let toViewController = maybeToViewController {
                toViewController.view.layoutIfNeeded()
                toViewController.bottomView.transform = CGAffineTransform(translationX: 0.0, y: toViewController.bottomView.frame.height + toViewController.view.safeAreaInsets.bottom)
                toViewController.bottomViewDimmedView?.alpha = 0.0
                addAnimations {
                    toViewController.bottomViewAdditionalAnimations(state: state, key: .to)
                    toViewController.bottomView.transform = CGAffineTransform(translationX: 0.0, y: 0.0)
                    toViewController.bottomViewDimmedView?.alpha = 1.0
                }
            } else if let fromViewController = maybeFromViewController {
                fromContainerViewController.view.alpha = 1.0
                fromViewController.bottomView.alpha = 1.0
                fromViewController.view.layoutIfNeeded()
                addAnimations {
                    fromViewController.bottomViewAdditionalAnimations(state: state, key: .from)
                    fromViewController.bottomView.transform = CGAffineTransform(translationX: 0.0, y: fromViewController.bottomView.frame.height + fromViewController.view.safeAreaInsets.bottom)
                    fromViewController.bottomViewDimmedView?.alpha = 0.0
                }
            }
        }
    }
}

/*
 BottomViewPropertyAnimator 대로 동작하나 case 1 은 무시되고 case 2 으로만 동작시킵니다.
 */
open class BottomViewModalPropertyAnimator: BottomViewPropertyAnimator {
    
    override open func onAnimate(context: UIViewControllerContextTransitioning, state: TransitionState?) {
        guard let fromContainerViewController = context.viewController(forKey: .from), let toContainerViewController = context.viewController(forKey: .to) else {
            return
        }
        
        let maybeFromViewController = pay.findViewControllerInContainerIfPossible(fromContainerViewController) as? (UIViewController & BottomViewAnimatable)
        let maybeToViewController = pay.findViewControllerInContainerIfPossible(toContainerViewController) as? (UIViewController & BottomViewAnimatable)

        // 2. to 만 BottomViewAnimatable 를 컨펌하고 있다면 present 일 경우로, BottomView 를 화면 하단에서 올라오는 효과를 줍니다. (dismiss 시에는 반대로)
        if (state == nil || state == .present), let toViewController = maybeToViewController {
            toViewController.bottomViewHeightConstraint.constant = 0.0
            toViewController.view.layoutIfNeeded()
            toViewController.bottomViewDimmedView?.alpha = 0.0
            addAnimations {
                toViewController.bottomViewAdditionalAnimations(state: state, key: .to)
                toViewController.bottomViewHeightConstraint.constant = toViewController.bottomViewDefaultHeight
                toViewController.view.layoutIfNeeded()
                toViewController.bottomViewDimmedView?.alpha = 1.0
            }
        } else if (state == .dismiss), let fromViewController = maybeFromViewController {
            if let toViewController = maybeToViewController {
                toViewController.bottomView.alpha = 1.0
            }
            fromContainerViewController.view.alpha = 1.0
            fromViewController.bottomView.alpha = 1.0
            addAnimations {
                fromViewController.bottomViewAdditionalAnimations(state: state, key: .from)
                fromViewController.bottomViewHeightConstraint.constant = 0.0
                fromViewController.view.layoutIfNeeded()
                fromViewController.bottomViewDimmedView?.alpha = 0.0
            }
        }
    }
}

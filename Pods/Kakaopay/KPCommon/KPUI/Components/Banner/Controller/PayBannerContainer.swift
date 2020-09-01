//
//  PayBannerContainer.swift
//  Kakaopay
//
//  Created by kali_company on 13/04/2019.
//

import UIKit

open class PayBannerContainer: UIViewController {
    
    private var configuration: BannerConfiguration!
    private var bannerContainer: UIViewController!

    override open func viewDidLoad() {
        super.viewDidLoad()

        prepareBanner()
    }
    
    private func prepareBanner() {
        switch configuration.unit.layout {
        case .single:
            bannerContainer = SingleBannerViewController.instantiate(configuration: configuration)
        case .horizontal, .vertical, .grid, .list:
            bannerContainer = SlideBannerViewController.instantiate(configuration: configuration as! BannerSlideConfiguration)
        }
        addChild(bannerContainer)
        view.addSubview(bannerContainer.view)
        bannerContainer.view.frame = CGRect(x: 0.0, y: 0.0, width: view.frame.width, height: view.frame.height)
        bannerContainer.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        bannerContainer.didMove(toParent: self)
    }
}

extension PayBannerContainer {
    static func instantiate(configuration: BannerConfiguration) -> PayBannerContainer {
        let viewController = UIStoryboard(name: "PayBanner", bundle: Bundle(for: self)).instantiateViewController(withIdentifier: "PayBannerContainer") as? PayBannerContainer
        viewController?.configuration = configuration
        return viewController!
    }
}

open class PayBottomBannerContainer: UIViewController, BottomViewAnimatable {
    fileprivate var configuration: BannerConfiguration!
    fileprivate var bannerContainer: UIViewController!
    
    @IBOutlet public weak var bottomView: UIView!
    @IBOutlet public weak var bottomViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet public weak var bottomViewDimmedView: UIView?
    public var bottomViewDefaultHeight: CGFloat!
    
    @IBOutlet fileprivate weak var bannerBaseView: UIView!
    
    class func instantiate(configuration: BannerConfiguration) -> PayBottomBannerContainer? {
        let viewController = UIStoryboard(name: "PayBanner", bundle: Bundle(for: self)).instantiateViewController(withIdentifier: "PayBottomBannerContainer") as? PayBottomBannerContainer
        viewController?.configuration = configuration
        viewController?.modalPresentationStyle = .custom
        viewController?.transitioningHandler.isEnabled = true

        return viewController
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        bottomView.layer.cornerRadius = 16.0
        (bottomView as? RoundedView)?.setupRound()

        prepareBanner()
    }
    
    private func prepareBanner() {
        switch configuration.unit.layout {
        case .single:
            bannerContainer = SingleBannerViewController.instantiate(configuration: configuration)
        case .horizontal, .vertical, .grid, .list:
            bannerContainer = SlideBannerViewController.instantiate(configuration: configuration as! BannerSlideConfiguration)
        }
        addChild(bannerContainer)
        bannerBaseView.addSubview(bannerContainer.view)
        bannerContainer.view.frame = CGRect(x: 0.0, y: 0.0, width: bannerBaseView.frame.width, height: bannerBaseView.frame.height)
        bannerContainer.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        bannerContainer.didMove(toParent: self)
        
        bottomViewDefaultHeight = bottomViewHeightConstraint.constant
    }
    
    @IBAction private func actionToCancel(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true)
    }
    
    public func transitionAnimatorPresentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> (UIPresentationController & TransitionHandleable)? {
        return PullToDismissPresentationController(presentedViewController: presented, presenting: presenting,
                                                   gestureDismissFraction: 0.3, gestureViewProvider: { return self.bannerBaseView }) // gesture 영역이 특정 view 에만 국한될 경우 제공.
    }
}

open class PayFloatingBannerContainer: PayBottomBannerContainer {
    override class func instantiate(configuration: BannerConfiguration) -> PayFloatingBannerContainer? {
        let viewController = UIStoryboard(name: "PayBanner", bundle: Bundle(for: self)).instantiateViewController(withIdentifier: "PayFloatingBannerContainer") as? PayFloatingBannerContainer
        viewController?.configuration = configuration
        viewController?.modalPresentationStyle = .custom
        viewController?.transitioningHandler.isEnabled = true

        return viewController
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        bannerBaseView.layer.cornerRadius = 16.0
    }
}

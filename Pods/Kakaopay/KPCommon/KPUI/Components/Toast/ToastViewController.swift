//
//  ToastViewController.swift
//  KPUI
//
//  Created by henry on 2018. 2. 19..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import UIKit

public class ToastViewController: UIViewController {
    
    @IBOutlet weak var messageContainerView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    
    private var message: String = ""
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        messageContainerView.layer.cornerRadius = (messageContainerView.frame.height / 2 < 6.0) ? messageContainerView.frame.height / 2 : 6.0
        messageLabel.text = message
    }
}

extension ToastViewController: ToastPresentable {
    
    public static func instantiate(message: String) -> (UIViewController & ToastPresentable)? {
        guard let toastViewController: ToastViewController = instantiate(storyboardName: "Toast") else {
            return nil
        }
        
        toastViewController.message = message
        return toastViewController
    }
    
    public func updateMessage(message: String) {
        self.messageLabel.text = message
    }
}

extension ToastViewController: TransitionAnimatable {
    
    public func presentTransitionAnimator(context: UIViewControllerContextTransitioning) -> UIViewPropertyAnimator {
        return FadePropertyAnimator(context: context, state: .present, duration: 0.3, curve: .linear)
    }
    
    public func dismissTransitionAnimator(context: UIViewControllerContextTransitioning) -> UIViewPropertyAnimator {
        return FadePropertyAnimator(context: context, state: .dismiss, duration: 0.3, curve: .linear)
    }
}



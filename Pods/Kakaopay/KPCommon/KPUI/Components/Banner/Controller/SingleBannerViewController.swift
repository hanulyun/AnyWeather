//
//  SingleBannerViewController.swift
//  Kakaopay
//
//  Created by kali_company on 14/04/2019.
//

import UIKit

class SingleBannerViewController: UIViewController {
    @IBOutlet private weak var baseView: UIView!
    
    private var configuration: BannerConfiguration!
    
    private var content: PayAdContent? {
        return configuration.unit.contents.first
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if baseView.subviews.count == 0 {
            prepareBannerItem()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let content = content {
            configuration.didAppear?(content)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let content = content {
            configuration.didDisappear?(content)
        }
    }
    
    private func prepareBannerItem() {
        if let content = content {
            let banner = BannerHelper.loadBanner(content: content, cachePolicy: configuration.imageCachePolicy, didReady: { _, error in
                self.configuration.didReady?(content, error)
                self.configuration.didReady = nil
            })
            if let banner = banner as? ImageBannerView {
                banner.updateContentMode(configuration.contentMode)
            }
            banner.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            banner.frame = CGRect(x: 0.0, y: 0.0, width: baseView.frame.width, height: baseView.frame.height)
            baseView.addSubview(banner)
        }
    }
    
    @IBAction private func actionToBannerItem(_ sender: UITapGestureRecognizer) {
        if let content = content {
            configuration.didSelect?(content)
        }
    }
}

extension SingleBannerViewController {
    static func instantiate(configuration: BannerConfiguration) -> SingleBannerViewController {
        let viewController = UIStoryboard(name: "PayBanner", bundle: Bundle(for: self)).instantiateViewController(withIdentifier: "SingleBannerViewController") as? SingleBannerViewController
        viewController?.configuration = configuration
        return viewController!
    }
}

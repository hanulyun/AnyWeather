//
//  BannerHelper.swift
//  Kakaopay
//
//  Created by kali_company on 14/04/2019.
//

import Foundation
import UIKit

class BannerHelper {
    static func loadBanner(content: PayAdContent, cachePolicy: CacheType, didReady: BannerResultHandler? = nil) -> UIView {
        if content.contentType == .text {
            let banner = TextBannerView.loadFromNib()
            banner.updateContent(content)
            didReady?(content, nil)
            return banner
        } else {
            let banner = ImageBannerView.loadFromNib()
            banner.updateContent(content, cachePolicy: cachePolicy, didReady: didReady)
            return banner
        }
    }
}

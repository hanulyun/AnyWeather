//
//  ImageBannerView.swift
//  Kakaopay
//
//  Created by kali_company on 14/04/2019.
//

import UIKit

class ImageBannerView: UIView {
    @IBOutlet private weak var image: UIImageView!
    
    static func loadFromNib() -> ImageBannerView {
        return Bundle(for: self).loadNibNamed("ImageBannerView", owner: nil, options: nil)![0] as! ImageBannerView
    }

    func updateContent(_ content: PayAdContent, cachePolicy: CacheType, didReady: BannerResultHandler? = nil) {
        if let component = content.component {
            image.setImage(url: component.imageUrl, useCache: cachePolicy) { (_, error) in
                didReady?(content, error)
            }
            image.backgroundColor = content.bgColor ?? UIColor.clear
        }
    }
    
    func updateContentMode(_ contentMode: UIView.ContentMode) {
        image.contentMode = contentMode
    }
}

//
//  TextBannerView.swift
//  Kakaopay
//
//  Created by kali_company on 14/04/2019.
//

import UIKit

class TextBannerView: UIView {
    @IBOutlet private weak var title: UILabel!
    
    static func loadFromNib() -> TextBannerView {
        return Bundle(for: self).loadNibNamed("TextBannerView", owner: nil, options: nil)![0] as! TextBannerView
    }
    
    func updateContent(_ content: PayAdContent) {
        if let component = content.component {
            title.text = component.value
            self.backgroundColor = content.bgColor ?? UIColor.clear
        }
    }
}

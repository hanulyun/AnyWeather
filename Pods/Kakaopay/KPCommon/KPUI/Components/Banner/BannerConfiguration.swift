//
//  BannerConfiguration.swift
//  Kakaopay
//
//  Created by kali_company on 14/04/2019.
//

import Foundation

public typealias BannerHandler = (_ content: PayAdContent) -> Void
public typealias BannerResultHandler = (_ content: PayAdContent, _ error: Error?) -> Void

public class BannerConfiguration {
    public var unit: PayAdUnit
    public var contentMode = UIView.ContentMode.scaleAspectFit
    public var imageCachePolicy = CacheType.memory
    public var didSelect: BannerHandler? = nil
    public var didAppear: BannerHandler? = nil
    public var didDisappear: BannerHandler? = nil
    public var didLoad: BannerResultHandler? = nil
    var didReady: BannerResultHandler? = nil
    
    public init(unit: PayAdUnit, contentMode: UIView.ContentMode = .scaleAspectFit, didSelect: BannerHandler? = nil, didAppear: BannerHandler? = nil, didDisappear: BannerHandler? = nil, didLoad: BannerResultHandler? = nil) {
        self.unit = unit
        self.contentMode = contentMode
        self.didSelect = didSelect
        self.didAppear = didAppear
        self.didDisappear = didDisappear
        self.didLoad = didLoad
    }
}

public class BannerSlideConfiguration: BannerConfiguration {
    public enum PageControlPosition {
        case topLeft, topCenter, topRight, bottomLeft, bottomCenter, bottomRight, hidden
    }
    
    public var pageControlPosition = PageControlPosition.bottomCenter
    
    public init(unit: PayAdUnit, pageControlPosition: PageControlPosition, contentMode: UIView.ContentMode = .scaleAspectFit , didSelect: BannerHandler? = nil, didAppear: BannerHandler? = nil, didDisappear: BannerHandler? = nil) {
        self.pageControlPosition = pageControlPosition
        
        super.init(unit: unit, contentMode: contentMode, didSelect: didSelect, didAppear: didAppear, didDisappear: didDisappear)
    }
}

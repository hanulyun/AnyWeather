//
//  PayAd.swift
//  Kakaopay
//
//  Created by kali_company on 13/04/2019.
//

import Foundation

open class PayAdUnit: Codable {
    public enum Layout: String {
        case single = "SINGLE"
        case horizontal = "HORIZONTAL_SLIDE"
        case vertical = "VERTICAL_SLIDE"
        case list = "LIST"
        case grid = "GRID"
    }
    
    enum CodingKeys: String, CodingKey {
        case unitId = "ad_unit_id"
        case layout = "ad_unit_layout"
        case displayCount = "ad_content_total_count"
        case contents = "ad_contents"
        case interval = "ad_unit_exposure_interval"
    }
    
    private(set) public var unitId = ""
    private(set) public var layout = Layout.single
    private(set) public var displayCount = 0
    private(set) public var interval: TimeInterval = 0.0
    private(set) public var contents = [PayAdContent]()
    
    public var bannerIdentifier: String? {
        if let content = contents.first {
            return "\(unitId):\(content.contentId)"
        }
        return nil
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        unitId = (try? values.decode(String.self, forKey: .unitId)) ?? ""
        layout = Layout(rawValue: ((try? values.decode(String.self, forKey: .layout)) ?? "SINGLE")) ?? .single
        let contents = (try? values.decode([PayAdContent].self, forKey: .contents)) ?? [PayAdContent]()
        self.contents = contents.sorted(by: { $0.order < $1.order })
        displayCount = (try? values.decode(Int.self, forKey: .displayCount)) ?? contents.count
        let milliInterval = (try? values.decode(Int.self, forKey: .interval)) ?? 0
        interval = Double(milliInterval) / 1000.0
    }
    
    public init(dictionary: [String:Any]) {
        unitId = dictionary[CodingKeys.unitId.rawValue] as? String ?? ""
        layout = Layout(rawValue: (dictionary[CodingKeys.layout.rawValue] as? String) ?? "SINGLE") ?? .single
        let contentsArray = dictionary[CodingKeys.contents.rawValue] as? [[String:Any]] ?? [[String:Any]]()
        var contents = [PayAdContent]()
        for dic in contentsArray {
            contents.append(PayAdContent(dictionary: dic))
        }
        self.contents = contents
        self.contents = self.contents.sorted(by: { $0.order < $1.order })
        displayCount = dictionary[CodingKeys.displayCount.rawValue] as? Int ?? 0
        let milliInterval = dictionary[CodingKeys.interval.rawValue] as? Int ?? 0
        interval = Double(milliInterval) / 1000.0
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(unitId, forKey: .unitId)
        try container.encode(layout.rawValue, forKey: .layout)
        try container.encode(contents, forKey: .contents)
        try container.encode(displayCount, forKey: .displayCount)
        try container.encode(interval*1000, forKey: .interval)
    }
    
    init() {}
}

open class PayAdContent: Codable {
    public enum ContentType: String {
        case image = "IMAGE_BANNER"
        case text = "TEXT_BANNER"
    }
    
    enum CodingKeys: String, CodingKey {
        case contentId = "content_id"
        case campaignId = "campaign_id"
        case order = "ad_position"
        case title = "content_title"
        case contentType = "content_type"
        case isAd = "ad_yn"
        case bgImageUrl = "content_bg_img_url"
        case bgColor = "content_bg_color"
        case components = "components"
    }
    
    private(set) public var contentId = ""
    private(set) public var campaignId = ""
    private(set) public var order = 1
    private(set) public var title: String?
    private(set) public var contentType = ContentType.text
    private(set) public var isAd = true
    private(set) public var bgImageUrl: URL?
    private(set) public var bgColor: UIColor?
    private(set) public var components = [PayAdComponent]()
    
    var component: PayAdComponent? {
        return components.first
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        contentId = (try? values.decode(String.self, forKey: .contentId)) ?? ""
        campaignId = (try? values.decode(String.self, forKey: .campaignId)) ?? ""
        order = (try? values.decode(Int.self, forKey: .order)) ?? 1
        title = try? values.decode(String.self, forKey: .title)
        contentType = ContentType(rawValue: ((try? values.decode(String.self, forKey: .contentType)) ?? "TEXT_BANNER")) ?? .text
        let adYN = (try? values.decode(String.self, forKey: .isAd)) ?? "N"
        isAd = adYN.uppercased() == "Y" ? true : false
        bgImageUrl = try? values.decode(URL.self, forKey: .bgImageUrl)
        if let color = try? values.decode(String.self, forKey: .bgColor) {
            bgColor = UIColor.pay.hex(color)
        }
        components = (try? values.decode([PayAdComponent].self, forKey: .components)) ?? [PayAdComponent]()
    }
    
    public init(dictionary: [String:Any]) {
        contentId = dictionary[CodingKeys.contentId.rawValue] as? String ?? ""
        campaignId = dictionary[CodingKeys.campaignId.rawValue] as? String ?? ""
        order = dictionary[CodingKeys.order.rawValue] as? Int ?? 1
        title = dictionary[CodingKeys.title.rawValue] as? String
        contentType = ContentType(rawValue: (dictionary[CodingKeys.contentType.rawValue] as? String) ?? "TEXT_BANNER") ?? .text
        let adYN = dictionary[CodingKeys.isAd.rawValue] as? String ?? "N"
        isAd = adYN.uppercased() == "Y" ? true : false
        bgImageUrl = URL(string: dictionary[CodingKeys.bgImageUrl.rawValue] as? String ?? "")
        if let color = dictionary[CodingKeys.bgColor.rawValue] as? String {
            bgColor = UIColor.pay.hex(color)
        }
        let componentsArray = dictionary[CodingKeys.components.rawValue] as? [[String:Any]] ?? [[String:Any]]()
        var components = [PayAdComponent]()
        for dic in componentsArray {
            components.append(PayAdComponent(dictionary: dic))
        }
        self.components = components
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(contentId, forKey: .contentId)
        try container.encode(campaignId, forKey: .campaignId)
        try container.encode(order, forKey: .order)
        try container.encode(title, forKey: .title)
        try container.encode(contentType.rawValue, forKey: .contentType)
        try container.encode((isAd ? "Y" : "N"), forKey: .isAd)
        try container.encode(bgImageUrl, forKey: .bgImageUrl)
        if let color = self.bgColor {
            try container.encode(color.pay.hexString, forKey: .bgColor)
        } else {
            try container.encodeNil(forKey: .bgColor)
        }
        try container.encode(components, forKey: .components)
    }
    
    init() {}
}

open class PayAdComponent: Codable {
    public enum LandingType: String {
        case scheme = "SCHEME"
        case webview = "WEBVIEW"
        case browser = "BROWSER"
    }
    
    enum CodingKeys: String, CodingKey {
        case value = "value"
        case alt = "alt_text"
        case landing = "landing"
    }
    
    enum LandingCodingKeys: String, CodingKey {
        case ios = "ios"
    }
    
    enum iOSLandingCodingKeys: String, CodingKey {
        case landingType = "landing_type"
        case landingUrl = "landing_url"
    }
    
    private(set) public var landingType = LandingType.webview
    private(set) public var landingUrl: URL?
    private(set) public var value = ""
    private(set) public var alt: String?
    var imageUrl: URL? {
        return URL(string: value)
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let landing = try? values.nestedContainer(keyedBy: LandingCodingKeys.self, forKey: .landing)
        
        value = (try? values.decode(String.self, forKey: .value)) ?? ""
        alt = try? values.decode(String.self, forKey: .alt)
        if let landing = landing, let iOSLanding = try? landing.nestedContainer(keyedBy: iOSLandingCodingKeys.self, forKey: .ios) {
            landingType = LandingType(rawValue: ((try? iOSLanding.decode(String.self, forKey: .landingType)) ?? "WEBVIEW")) ?? .webview
            landingUrl = try? iOSLanding.decode(URL.self, forKey: .landingUrl)
        }
    }
    
    public init(dictionary: [String:Any]) {
        value = dictionary[CodingKeys.value.rawValue] as? String ?? ""
        alt = dictionary[CodingKeys.alt.rawValue] as? String
        if let landing = dictionary[CodingKeys.landing.rawValue] as? [String:Any], let iOSLanding = landing[LandingCodingKeys.ios.rawValue] as? [String:Any] {
            landingType = LandingType(rawValue: (iOSLanding[iOSLandingCodingKeys.landingType.rawValue] as? String) ?? "WEBVIEW") ?? .webview
            landingUrl = URL(string: iOSLanding[iOSLandingCodingKeys.landingUrl.rawValue] as? String ?? "")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var landingContainer = container.nestedContainer(keyedBy: LandingCodingKeys.self, forKey: .landing)
        var iosLandingContainer = landingContainer.nestedContainer(keyedBy: iOSLandingCodingKeys.self, forKey: .ios)
        try container.encode(value, forKey: .value)
        try container.encode(alt, forKey: .alt)
        try iosLandingContainer.encode(landingType.rawValue, forKey: .landingType)
        try iosLandingContainer.encode(landingUrl?.absoluteString, forKey: .landingUrl)
    }
    
    init() {}
}

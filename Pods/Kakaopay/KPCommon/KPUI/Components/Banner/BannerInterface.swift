//
//  BannerInterface.swift
//  Kakaopay
//
//  Created by kali_company on 13/04/2019.
//

import UIKit

public class BannerInterface {
    public enum BottomBannerType {
        case normal, floating
    }
    
    public static func bannerContainer(configuration: BannerConfiguration) -> UIViewController {
        return PayBannerContainer.instantiate(configuration: configuration)
    }
    
    public static func addBannerContainer(configuration: BannerConfiguration, container: ContainerViewController) {
        let banner = PayBannerContainer.instantiate(configuration: configuration)
        
        configuration.didReady = { content, error in
            guard error == nil else {
                configuration.didLoad?(content, error)
                return
            }
            
            container.add(content: banner, on: container.containerView(for: nil))
            
            configuration.didLoad?(content, nil)
        }
        _ = banner.view //add 하기전에 viewDidLoad가 호출되도록 하기 위해서.
    }
    
    public static func addBannerContainer(configuration: BannerConfiguration, on view: UIView, in container: UIViewController) {
        let banner = PayBannerContainer.instantiate(configuration: configuration)
        
        configuration.didReady = { content, error in
            guard error == nil else {
                configuration.didLoad?(content, error)
                return
            }
            
            container.addChild(banner)
            view.addSubview(banner.view)
            banner.view.frame = CGRect(x: 0.0, y: 0.0, width: view.frame.width, height: view.frame.height)
            banner.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

            banner.didMove(toParent: container)
            
            configuration.didLoad?(content, nil)
        }
        _ = banner.view //add 하기전에 viewDidLoad가 호출되도록 하기 위해서.
    }
    
    public static func presentBottomBannerContainer(on: UIViewController, configuration: BannerConfiguration, type: BottomBannerType = .normal) {
        let interval = configuration.unit.interval
        let key = "BannerInterfaceUnitInterval" + configuration.unit.unitId
                
        guard canDisplay(interval: interval, key: key) else { return }
                
        let container: PayBottomBannerContainer?
        switch type {
        case .normal:
            container = PayBottomBannerContainer.instantiate(configuration: configuration)
        case .floating:
            container = PayFloatingBannerContainer.instantiate(configuration: configuration)
        }
        
        configuration.didReady = { content, error in
            guard error == nil else {
                configuration.didLoad?(content, error)
                return
            }
            
            if let container = container {
                on.present(container, animated: true) {
                    if interval > 0 {
                        UserDefaults.standard.setValue(Date(), forKey: key)
                    }
                    configuration.didLoad?(content, nil)
                }
            }
        }
        _ = container?.view //present 하기전에 viewDidLoad가 호출되도록 하기 위해서.
    }
    
    private static func canDisplay(interval: TimeInterval, key: String) -> Bool {
        if let lastDisplayDate = UserDefaults.standard.value(forKey: key) as? Date {
            return Date().timeIntervalSince(lastDisplayDate) > interval
        }
        
        return true
    }
}

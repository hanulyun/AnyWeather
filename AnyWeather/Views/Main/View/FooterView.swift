//
//  FooterView.swift
//  AnyWeather
//
//  Created by Hanul Yun on 2020/06/06.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

class FooterView: CustomView {
    
    private var pageControl: CustomPagerControl = CustomPagerControl()
    
    private let listButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "listIcon"), for: .normal)
        button.alpha = 0.5
        return button
    }()
    
    init() {
        super.init(frame: .zero)
        
        self.setInit(.purple)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setPageControl(withOutGps numberOfPage: Int) {
        var controls: [PagerControl] = [.gps]
        for _ in 0..<numberOfPage {
            controls.append(.dot)
        }
        pageControl.setControls(controls: controls)
        pageControl.selectIndex(0)
    }
    
    func selectedPage(_ page: Int) {
        pageControl.selectIndex(page)
    }
    
    func listButtonTapEvent() {
//        listButton.addTarget(self, action: <#T##Selector#>, for: .touchUpInside)
    }
    
    override func configureAutolayouts() {
        [pageControl, listButton].forEach { addSubview($0) }
        
        pageControl.equalToCenter(to: self)
        
        listButton.equalToCenterY(yAnchor: self.centerYAnchor)
        listButton.equalToTrailing(toAnchor: self.trailingAnchor, offset: -16.adjusted)
        listButton.equalToSize(16.adjusted)
    }
}

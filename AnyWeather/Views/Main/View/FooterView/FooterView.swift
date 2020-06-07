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
    
    private let lineView: UIView = UIView().filledStyle(color: .color(.translucentMain))
    
    let listButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "listIcon"), for: .normal)
        button.alpha = 0.5
        return button
    }()
    
    var currentPageNum: Int = 0
    
    init() {
        super.init(frame: .zero)
        
        self.setInit()
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
        selectedPage(currentPageNum)
    }
    
    func selectedPage(_ page: Int) {
        pageControl.selectIndex(page)
        currentPageNum = page
    }
    
    override func configureAutolayouts() {
        [pageControl, listButton, lineView].forEach { addSubview($0) }
        
        pageControl.equalToCenter(to: self)
        
        listButton.equalToCenterY(yAnchor: self.centerYAnchor)
        listButton.equalToTrailing(toAnchor: self.trailingAnchor, offset: -16.adjusted)
        listButton.equalToSize(16.adjusted)
        
        lineView.equalToTop(toAnchor: self.topAnchor)
        lineView.equalToLeading(toAnchor: self.leadingAnchor)
        lineView.equalToTrailing(toAnchor: self.trailingAnchor)
        lineView.equalToHeight(1)
    }
}

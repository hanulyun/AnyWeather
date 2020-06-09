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
    
    let listContainerButton: UIButton = UIButton()
    private let listImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "listIcon"))
        imageView.alpha = 0.6
        return imageView
    }()
    
    var currentPageNum: Int = 0
    
    init() {
        super.init(frame: .zero)
        
        self.setInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setPageControl(numberOfPage: Int, firstId: Int) {
        var controls: [PagerControl] = []
        if firstId == 0 {
            controls.append(.gps)
        }
        
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
        [pageControl, listContainerButton, lineView].forEach { addSubview($0) }
        listContainerButton.addSubview(listImageView)
        
        pageControl.equalToCenter(to: self)
        
        listContainerButton.equalToCenterY(yAnchor: self.centerYAnchor)
        listContainerButton.equalToTrailing(toAnchor: self.trailingAnchor, offset: -16.adjusted)
        listContainerButton.equalToSize(25.adjusted)
        
        lineView.equalToTop(toAnchor: self.topAnchor)
        lineView.equalToLeading(toAnchor: self.leadingAnchor)
        lineView.equalToTrailing(toAnchor: self.trailingAnchor)
        lineView.equalToHeight(1)
        
        listImageView.equalToSize(16.adjusted)
        listImageView.equalToCenter(to: listContainerButton)
    }
}

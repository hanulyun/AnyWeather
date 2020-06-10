//
//  ListTailTableViewCell.swift
//  AnyWeather
//
//  Created by Hanul Yun on 2020/06/07.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

class ListTailTableViewCell: UITableViewCell {
    static let reuseId: String = "ListTailTableViewCell"
    
    private let containerButton: UIButton = UIButton()
    private let degLabel: UILabel = UILabel()
    
    private let addContainerButton: UIButton = UIButton()
    private let addImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "addIcon"))
        return imageView
    }()
    
    var buttonTapEvent: ((ButtonTag) -> Void)?
    
    var isCflag: Bool = true
    
    enum ButtonTag {
        case deg
        case add
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        selectionStyle = .none
        
        configureAutolayouts()
        
        buttonEvent()
        
        setData(isCflag)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setData(_ isC: Bool) {
        let formatStr: NSMutableAttributedString = NSMutableAttributedString()
        let cColor: UIColor = isC ? .color(.main) : .color(.translucentMain)
        let fColor: UIColor = isC ? .color(.translucentMain) : .color(.main)
        
        formatStr.custom("\(degSymbol)C", color: cColor, font: .font(.subMiddle))
        formatStr.custom(" / ", color: .color(.translucentMain), font: .font(.subMiddle))
        formatStr.custom("\(degSymbol)F", color: fColor, font: .font(.subMiddle))
        
        degLabel.attributedText = formatStr
    }
    
    private func buttonEvent() {
        containerButton.addTarget(self, action: #selector(degButtonTap), for: .touchUpInside)
        addContainerButton.addTarget(self, action: #selector(addButtonTap), for: .touchUpInside)
    }
    
    @objc func degButtonTap() {
        self.buttonTapEvent?(.deg)
        isCflag = !isCflag
        setData(isCflag)
    }
    
    @objc func addButtonTap() {
        self.buttonTapEvent?(.add)
    }
}

extension ListTailTableViewCell {
    private func configureAutolayouts() {
        [containerButton, addContainerButton].forEach { addSubview($0) }
        containerButton.addSubview(degLabel)
        addContainerButton.addSubview(addImageView)
        
        containerButton.equalToTop(toAnchor: self.topAnchor, offset: 12.adjusted)
        containerButton.equalToLeading(toAnchor: self.leadingAnchor, offset: 16.adjusted)
        containerButton.equalToBottom(toAnchor: self.bottomAnchor, offset: -12.adjusted)
        
        addContainerButton.equalToTrailing(toAnchor: self.trailingAnchor, offset: -16.adjusted)
        addContainerButton.equalToCenterY(yAnchor: containerButton.centerYAnchor)
        addContainerButton.equalToSize(40.adjusted)
        
        degLabel.equalToEdges(to: containerButton, offset: 4.adjusted)
        
        addImageView.equalToSize(20.adjusted)
        addImageView.equalToCenter(to: addContainerButton)
    }
}

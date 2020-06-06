//
//  TodayCommentTVC.swift
//  AnyWeather
//
//  Created by Hanul Yun on 2020/06/06.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import UIKit

class TodayCommentTVC: UITableViewCell {
    static let reuseIdentifer: String = "TodayCommentTVC"
    
    private let commentLabel: UILabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .darkGray
        selectionStyle = .none
        
        configureAutolayouts()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setData() {
        commentLabel.numberOfLines = 0
        commentLabel.setFont(.font(.subSmall), color: .color(.main))
        commentLabel.text = "오늘은 대체로 어쩌구 저쩌구 내일은 어떻고 저떻고 최고 기온이\n 어떻고 알알알 내일은 맑을지 잘 모르겠\n음."
    }
}

extension TodayCommentTVC {
    private func configureAutolayouts() {
        addSubview(commentLabel)
        
        commentLabel.equalToTop(toAnchor: self.topAnchor, offset: 16.adjusted)
        commentLabel.equalToLeading(toAnchor: self.leadingAnchor, offset: 16.adjusted)
        commentLabel.equalToTrailing(toAnchor: self.trailingAnchor, offset: -16.adjusted)
        commentLabel.equalToBottom(toAnchor: self.bottomAnchor, offset: -16.adjusted)
    }
}

//
//  GridStackView.swift
//  Kakaopay
//
//  Created by pony.tail on 31/10/2019.
//

import UIKit

/*
  동일한 사이즈의 뷰가 그리드 형태로 좌측 상단부터 차곡차곡 채워지는 형태의 StackView
  Vertical StackView가 여러 개의 Horizontal StackView를 품고있습니다.
*/
open class GridStackView: UIStackView {
    
    @IBInspectable public var column: Int = 1 {
        didSet {
            if column <= 0 { column = 1 }
        }
    }
    
    @IBInspectable public var horizontalSpacing: CGFloat = 0
    
    required public init(coder: NSCoder) {
        super.init(coder: coder)
        axis = .vertical
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        axis = .vertical
    }
    
    open var nextIndexPath: IndexPath {
        let count = arrangedSubviews.reduce(0) {
            $0 + (($1 as? UIStackView)?.arrangedSubviews.count ?? 0)
        }
        return IndexPath(item: count % column, section: count / column)
    }
    
    open func addArrangedSubviews(_ views: [UIView]) {
        clearEmptyViews()
        for view in views {
            if nextIndexPath.item == 0 {
                let rowStackView = UIStackView()
                rowStackView.distribution = .fillEqually
                rowStackView.spacing = horizontalSpacing
                addArrangedSubview(rowStackView)
            }
            (arrangedSubviews[nextIndexPath.section] as? UIStackView)?.addArrangedSubview(view)
        }
        fillEmptyViews()
    }
    
    open func clearArrangedSubviews() {
        arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
    
    /*
     내부적으로 빈 그리드 공간을 임시로 채워주는 뷰 로직
     */
    private var emptyViews: [UIView] = []
    
    private func clearEmptyViews() {
        emptyViews.forEach { $0.removeFromSuperview() }
    }
    
    private func fillEmptyViews() {
        while nextIndexPath.item > 0 {
            let emptyView = UIView()
            emptyViews.append(emptyView)
            (arrangedSubviews[nextIndexPath.section] as? UIStackView)?.addArrangedSubview(emptyView)
        }
    }
}


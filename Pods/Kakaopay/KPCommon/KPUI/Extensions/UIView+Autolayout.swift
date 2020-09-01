//
//  UIView+Autolayout.swift
//  KPUI
//
//  Created by henry on 2018. 2. 2..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import UIKit

extension Pay where Base: UIView {
    public var fillAnchor: LayoutFillAnchors {
        return base.fillAnchor
    }
    public var fillWidthAnchor: LayoutFillAnchors {
        return base.fillWidthAnchor
    }
    public var fillHeightAnchor: LayoutFillAnchors {
        return base.fillHeightAnchor
    }
    public var sizeAnchor: LayoutSizeAnchors {
        return base.sizeAnchor
    }
}

extension Pay where Base: UILayoutGuide {
    public var fillAnchor: LayoutFillAnchors {
        return base.fillAnchor
    }
    public var fillWidthAnchor: LayoutFillAnchors {
        return base.fillWidthAnchor
    }
    public var fillHeightAnchor: LayoutFillAnchors {
        return base.fillHeightAnchor
    }
    public var sizeAnchor: LayoutSizeAnchors {
        return base.sizeAnchor
    }
}



protocol LayoutFillAnchorSupport {
    
    var fillAnchor: LayoutFillAnchors { get }
    var fillWidthAnchor: LayoutFillAnchors { get }
    var fillHeightAnchor: LayoutFillAnchors { get }
}

extension UIView {
    
    internal var fillAnchor: LayoutFillAnchors {
        return LayoutFillAnchors(leadingAnchor: leadingAnchor, trailingAnchor: trailingAnchor, topAnchor: topAnchor, bottomAnchor: bottomAnchor)
    }
    
    internal var fillWidthAnchor: LayoutFillAnchors {
        return LayoutFillAnchors(leadingAnchor: leadingAnchor, trailingAnchor: trailingAnchor, topAnchor: nil, bottomAnchor: nil)
    }
    
    internal var fillHeightAnchor: LayoutFillAnchors {
        return LayoutFillAnchors(leadingAnchor: nil, trailingAnchor: nil, topAnchor: topAnchor, bottomAnchor: bottomAnchor)
    }
    
    internal var sizeAnchor: LayoutSizeAnchors {
        return LayoutSizeAnchors(widthAnchor: widthAnchor, heightAnchor: heightAnchor)
    }
}

extension UILayoutGuide {
    
    internal var fillAnchor: LayoutFillAnchors {
        return LayoutFillAnchors(leadingAnchor: leadingAnchor, trailingAnchor: trailingAnchor, topAnchor: topAnchor, bottomAnchor: bottomAnchor)
    }
    
    internal var fillWidthAnchor: LayoutFillAnchors {
        return LayoutFillAnchors(leadingAnchor: leadingAnchor, trailingAnchor: trailingAnchor, topAnchor: nil, bottomAnchor: nil)
    }
    
    internal var fillHeightAnchor: LayoutFillAnchors {
        return LayoutFillAnchors(leadingAnchor: nil, trailingAnchor: nil, topAnchor: topAnchor, bottomAnchor: bottomAnchor)
    }
    
    internal var sizeAnchor: LayoutSizeAnchors {
        return LayoutSizeAnchors(widthAnchor: widthAnchor, heightAnchor: heightAnchor)
    }
}

open class LayoutAnchors {
    
    public enum CompareType {
        case equalTo
        case greaterThanOrEqualTo
        case lessThanOrEqualTo
    }
    
    public func calculateConstraint<AnchorType>(_ source: NSLayoutAnchor<AnchorType>?, _ target: NSLayoutAnchor<AnchorType>?, _ c: CGFloat, _ type: CompareType) -> NSLayoutConstraint? {
        guard let source = source, let target = target else {
            return nil
        }
        
        switch type {
        case .equalTo:
            return source.constraint(equalTo: target, constant: c)
        case .greaterThanOrEqualTo:
            return source.constraint(greaterThanOrEqualTo: target, constant: c)
        case .lessThanOrEqualTo:
            return source.constraint(lessThanOrEqualTo: target, constant: c)
        }
    }
}

open class LayoutSizeAnchors: LayoutAnchors {
    private let widthAnchor: NSLayoutDimension
    private let heightAnchor: NSLayoutDimension
    
    init(widthAnchor: NSLayoutDimension, heightAnchor: NSLayoutDimension) {
        self.widthAnchor = widthAnchor
        self.heightAnchor = heightAnchor
    }
    
    open func constraints(equalToConstant c: CGSize) -> LayoutConstraints {
        let constraints = LayoutConstraints()
        constraints.append(constraint: widthAnchor.constraint(equalToConstant: c.width))
        constraints.append(constraint: heightAnchor.constraint(equalToConstant: c.height))
        return constraints
    }

    open func constraints(greaterThanOrEqualToConstant c: CGSize) -> LayoutConstraints {
        let constraints = LayoutConstraints()
        constraints.append(constraint: widthAnchor.constraint(greaterThanOrEqualToConstant: c.width))
        constraints.append(constraint: heightAnchor.constraint(greaterThanOrEqualToConstant: c.height))
        return constraints
    }
    
    open func constraints(lessThanOrEqualToConstant c: CGSize) -> LayoutConstraints {
        let constraints = LayoutConstraints()
        constraints.append(constraint: widthAnchor.constraint(lessThanOrEqualToConstant: c.width))
        constraints.append(constraint: heightAnchor.constraint(lessThanOrEqualToConstant: c.height))
        return constraints
    }
    
    open func constraint(equalTo anchor: LayoutSizeAnchors, multiplier: (width: CGFloat, height: CGFloat)) -> LayoutConstraints {
        let constraints = LayoutConstraints()
        constraints.append(constraint: widthAnchor.constraint(equalTo: anchor.widthAnchor, multiplier: multiplier.width))
        constraints.append(constraint: heightAnchor.constraint(equalTo: anchor.heightAnchor, multiplier: multiplier.height))
        return constraints
    }
    
    open func constraint(greaterThanOrEqualTo anchor: LayoutSizeAnchors, multiplier: (width: CGFloat, height: CGFloat)) -> LayoutConstraints {
        let constraints = LayoutConstraints()
        constraints.append(constraint: widthAnchor.constraint(greaterThanOrEqualTo: anchor.widthAnchor, multiplier: multiplier.width))
        constraints.append(constraint: heightAnchor.constraint(greaterThanOrEqualTo: anchor.heightAnchor, multiplier: multiplier.height))
        return constraints
    }
    
    open func constraint(lessThanOrEqualTo anchor: LayoutSizeAnchors, multiplier: (width: CGFloat, height: CGFloat)) -> LayoutConstraints {
        let constraints = LayoutConstraints()
        constraints.append(constraint: widthAnchor.constraint(lessThanOrEqualTo: anchor.widthAnchor, multiplier: multiplier.width))
        constraints.append(constraint: heightAnchor.constraint(lessThanOrEqualTo: anchor.heightAnchor, multiplier: multiplier.height))
        return constraints
    }
}

open class LayoutFillAnchors: LayoutAnchors {
    
    private let trailingAnchor: NSLayoutXAxisAnchor?
    private let leadingAnchor: NSLayoutXAxisAnchor?
    private let topAnchor: NSLayoutYAxisAnchor?
    private let bottomAnchor: NSLayoutYAxisAnchor?
    
    init(leadingAnchor: NSLayoutXAxisAnchor?, trailingAnchor: NSLayoutXAxisAnchor?, topAnchor: NSLayoutYAxisAnchor?, bottomAnchor: NSLayoutYAxisAnchor?) {
        self.leadingAnchor = leadingAnchor
        self.trailingAnchor = trailingAnchor
        self.topAnchor = topAnchor
        self.bottomAnchor = bottomAnchor
    }

    open func constraints(equalTo anchor: LayoutFillAnchors, constant c: CGFloat = 0.0) -> LayoutConstraints {
        let constraints = LayoutConstraints()
        constraints.append(constraint: calculateConstraint(anchor.trailingAnchor, self.trailingAnchor, c, .equalTo))
        constraints.append(constraint: calculateConstraint(anchor.bottomAnchor, self.bottomAnchor, c, .equalTo))
        constraints.append(constraint: calculateConstraint(self.leadingAnchor, anchor.leadingAnchor, c, .equalTo))
        constraints.append(constraint: calculateConstraint(self.topAnchor, anchor.topAnchor, c, .equalTo))
        return constraints
    }
    
    open func constraints(greaterThanOrEqualTo anchor: LayoutFillAnchors, constant c: CGFloat = 0.0) -> LayoutConstraints {
        let constraints = LayoutConstraints()
        constraints.append(constraint: calculateConstraint(anchor.trailingAnchor, self.trailingAnchor, c, .greaterThanOrEqualTo))
        constraints.append(constraint: calculateConstraint(anchor.bottomAnchor, self.bottomAnchor, c, .greaterThanOrEqualTo))
        constraints.append(constraint: calculateConstraint(self.leadingAnchor, anchor.leadingAnchor, c, .greaterThanOrEqualTo))
        constraints.append(constraint: calculateConstraint(self.topAnchor, anchor.topAnchor, c, .greaterThanOrEqualTo))
        return constraints
    }

    open func constraints(lessThanOrEqualTo anchor: LayoutFillAnchors, constant c: CGFloat = 0.0) -> LayoutConstraints {
        let constraints = LayoutConstraints()
        constraints.append(constraint: calculateConstraint(anchor.trailingAnchor, self.trailingAnchor, c, .lessThanOrEqualTo))
        constraints.append(constraint: calculateConstraint(anchor.bottomAnchor, self.bottomAnchor, c, .lessThanOrEqualTo))
        constraints.append(constraint: calculateConstraint(self.leadingAnchor, anchor.leadingAnchor, c, .lessThanOrEqualTo))
        constraints.append(constraint: calculateConstraint(self.topAnchor, anchor.topAnchor, c, .lessThanOrEqualTo))
        return constraints
    }
}

public class LayoutConstraints {

    public var constraints: [NSLayoutConstraint] = []
    
    fileprivate func append(constraint: NSLayoutConstraint?) {
        guard let constraint = constraint else {
            return
        }
        constraints.append(constraint)
    }
    
    public var isActive: Bool {
        set {
            for constraint in constraints {
                constraint.isActive = newValue
            }
        }
        get {
            var value = false
            for constraint in constraints {
                value = constraint.isActive
                if !value { return value }
            }
            return value
        }
    }
}


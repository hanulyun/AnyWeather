//
//  SquarePatternView.swift
//  Kakaopay
//
//  Created by BLICK on 26/08/2019.
//

import UIKit

class SquarePatternView: UIView {
    static let squareSize: CGFloat = 21.1
    private var color: UIColor = UIColor.black
    
    init(frame: CGRect, color: UIColor) {
        super.init(frame: frame)
        self.color = color
        isOpaque = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var drawPattern: CGPatternDrawPatternCallback = { _, context in
        let rectanglePath = UIBezierPath(rect: CGRect(x: -1, y: -1, width: SquarePatternView.squareSize, height: SquarePatternView.squareSize))
        rectanglePath.lineWidth = 1
        context.addPath(rectanglePath.cgPath)
        context.setStrokeColor(UIColor.pay.rgb(r: 241, g: 243, b: 245).cgColor)
        context.strokePath()
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        UIColor.clear.setFill()
        context.fill(rect)
        
        var callbacks = CGPatternCallbacks(version: 0, drawPattern: drawPattern, releaseInfo: nil)
        let pattern = CGPattern(info: nil, bounds: CGRect(x: 0, y: 0, width: SquarePatternView.squareSize, height: SquarePatternView.squareSize),
                                matrix: .identity, xStep: SquarePatternView.squareSize, yStep: SquarePatternView.squareSize,
                                tiling: .noDistortion, isColored: false, callbacks: &callbacks)
        
        let patternSpace = CGColorSpace(patternBaseSpace: nil)!
        context.setFillColorSpace(patternSpace)
        var alpha: CGFloat = 1
        
        context.setFillPattern(pattern!, colorComponents: &alpha)
        context.fill(rect)
    }
}

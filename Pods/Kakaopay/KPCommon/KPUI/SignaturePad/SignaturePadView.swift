//
//  SignaturePadView.swift
//  Kakaopay
//
//  Created by BLICK on 21/08/2019.
//

import UIKit

public protocol SignaturePadDelegate: class {
    func signaturePad(hasContent: Bool)
    func signaturePad(image: UIImage?, data: Data?)
}

extension SignaturePadDelegate {
    func signaturePad(hasContent: Bool) { }
}

public class SignaturePadView: UIView {
    public weak var delegate: SignaturePadDelegate? {
        get { return drawingPadView.delegate }
        set { drawingPadView.delegate = newValue }
    }
    public var visibleStrokeColor: UIColor {
        get { return drawingPadView.visibleColor }
        set { drawingPadView.visibleColor = newValue }
    }
    public var exportStrokeColor: UIColor {
        get { return drawingPadView.exportColor }
        set { drawingPadView.exportColor = newValue }
    }
    public var lineDrawingType: DrawingPadView.LineDrawingType {
        get { return drawingPadView.lineDrawingType }
        set { drawingPadView.lineDrawingType = newValue }
    }
    public var isShowBackgroundPattern: Bool = false {
        didSet {
            setupBackgroundPattern()
        }
    }
    
    private(set) var drawingPadView: DrawingPadView!
    private(set) var backgroundPatternView: SquarePatternView?
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        clipsToBounds = true
        setupDrawingPad()
        setupBackgroundPattern()
    }
    
    public func resetPad() {
        drawingPadView.resetPad()
    }
    
    private func setupBackgroundPattern() {
        guard isShowBackgroundPattern, backgroundPatternView == nil else { return }
        backgroundPatternView = SquarePatternView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height), color: .red)
        addSubview(backgroundPatternView!)
        bringSubviewToFront(drawingPadView)
        
        backgroundPatternView!.translatesAutoresizingMaskIntoConstraints = false
        backgroundPatternView!.topAnchor.constraint(equalTo: topAnchor).isActive = true
        backgroundPatternView!.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        backgroundPatternView!.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        backgroundPatternView!.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    private func setupDrawingPad() {
        drawingPadView = DrawingPadView()
        addSubview(drawingPadView)
        
        drawingPadView.translatesAutoresizingMaskIntoConstraints = false
        drawingPadView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        drawingPadView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        drawingPadView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        drawingPadView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
}




/*
public class SignaturePadView: UIView {
    public weak var delegate: SignaturePadDelegate?
    
    private var drawingPath: UIBezierPath = UIBezierPath()
    private var cachedImage: UIImage = UIImage()
    private var count = 0
    private var locations = [CGPoint](repeating: .zero, count: 5)
    
    
    var pattern: SquarePatternView!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        pattern = SquarePatternView(frame: frame, color: UIColor.green)
        //        layer.addSublayer(pattern.layer)
        //        addSubview(pattern)
        //        insertSubview(pattern, belowSubview: self)
    }
    
    public override func draw(_ rect: CGRect) {
        UIColor.pay.rgb(r: 90, g: 90, b: 92).setStroke()
        
        drawingPath.stroke()
        delegate?.signaturePad(self, hasContent: !drawingPath.isEmpty)
    }
    
    private func setupView() {
        setupBezierPath()
    }
    
    private func setupBezierPath() {
        drawingPath = UIBezierPath()
        drawingPath.lineWidth = 6
        drawingPath.lineCapStyle = .round
    }
    
    private func drawImage() {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0)
        cachedImage.draw(at: .zero)
        UIColor.pay.rgb(r: 90, g: 90, b: 92).setStroke()
        drawingPath.stroke()
        
        if let currentImage = UIGraphicsGetImageFromCurrentImageContext() {
            cachedImage = currentImage
        }
        UIGraphicsEndImageContext()
    }
    
    public func resetPad() {
        drawingPath.removeAllPoints()
        
        cachedImage = UIImage()
        delegate?.signaturePad(self, image: cachedImage, data: nil)
        
        setNeedsDisplay()
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touches = touches.first else { return }
        let point = touches.location(in: self)
        count = 0
        locations[0] = point
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touches = touches.first else { return }
        let point = touches.location(in: self)
        
        count += 1
        locations[count] = point
        if count == 4 {
            locations[3] = CGPoint(x: (locations[2].x + locations[4].x) / 2,
                                   y: (locations[2].y + locations[4].y) / 2)
            drawingPath.move(to: locations[0])
            drawingPath.addCurve(to: locations[3], controlPoint1: locations[1], controlPoint2: locations[2])
            setNeedsDisplay()
            
            locations[0] = locations[3]
            locations[1] = locations[4]
            count = 1
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        count = 0
        drawImage()
        setNeedsDisplay()
        
        delegate?.signaturePad(self, image: cachedImage, data: cachedImage.pngData())
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchesEnded(touches, with: event)
    }
}
*/

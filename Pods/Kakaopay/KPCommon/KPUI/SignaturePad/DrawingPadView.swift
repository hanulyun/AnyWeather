//
//  DrawingPadView.swift
//  Kakaopay
//
//  Created by BLICK on 03/09/2019.
//

import UIKit

public class DrawingPadView: UIView {
    public enum LineDrawingType {
        case normal(width: CGFloat)
        case interaction(minWidth: CGFloat, maxWidth: CGFloat)
    }
    
    public weak var delegate: SignaturePadDelegate?
    public var visibleColor: UIColor = .black
    public var exportColor: UIColor = .black
    public var lineDrawingType: LineDrawingType = .normal(width: 6)
    private(set) var drawedImage: UIImage = UIImage()
    
    private var activeStroke: Stroke? = nil
    private var strokes: [Stroke] = []
    private var finishedStrokes: [Stroke] = []
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        isOpaque = false
        clipsToBounds = true
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        var hasPaths: Bool = false
        for stroke in strokes {
            stroke.draw()
            hasPaths = hasPaths || !stroke.isPathEmpty
        }
        
        for stroke in finishedStrokes {
            stroke.draw()
            hasPaths = hasPaths || !stroke.isPathEmpty
        }
        delegate?.signaturePad(hasContent: hasPaths)
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        drawTouches(touches, event: event)
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        drawTouches(touches, event: event)
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        drawTouches(touches, event: event)
        endTouches(touches)
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.touchesEnded(touches, with: event)
    }
    
    public func resetPad() {
        activeStroke = nil
        strokes = []
        finishedStrokes = []
        
        drawedImage = UIImage()
        setNeedsDisplay()
        delegate?.signaturePad(image: drawedImage, data: nil)
    }
    
    private func drawTouches(_ touches: Set<UITouch>, event: UIEvent?) {
        var updateRect: CGRect = .null
        
        for touch in touches {
            let stroke = activeStroke ?? addActiveStroke(touch: touch)
            
            let coalescedTouches = event?.coalescedTouches(for: touch) ?? []
            let coalescedRect: CGRect = addPointsOfType(touches: coalescedTouches, to: stroke, in: updateRect)
            updateRect = updateRect.union(coalescedRect)
        }
        setNeedsDisplay(updateRect)
    }
    
    private func addActiveStroke(touch: UITouch) -> Stroke {
        let newStroke = Stroke()
        activeStroke = newStroke
        strokes.append(newStroke)
        return newStroke
    }
    
    private func addPointsOfType(touches: [UITouch], to stroke: Stroke, in updateRect: CGRect) -> CGRect {
        var accumulatedRect = CGRect.null
        
        for touch in touches {
            let touchRect = stroke.addPoint(touch: touch, lineDrawingType: lineDrawingType, color: visibleColor, in: self)
            accumulatedRect = accumulatedRect.union(touchRect)
        }
        
        return updateRect.union(accumulatedRect)
    }
    
    private func endTouches(_ touches: Set<UITouch>) {
        if let stroke = activeStroke {
            strokes.removeLast()
            finishedStrokes.append(stroke)
            activeStroke = nil
        }
        setNeedsDisplay()
        makeImage()
    }
    
    private func makeImage() {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0)
        drawedImage.draw(at: .zero)
        exportColor.setStroke()
        
        for stroke in finishedStrokes {
            stroke.draw(color: exportColor)
        }
        
        if let currentImage = UIGraphicsGetImageFromCurrentImageContext() {
            drawedImage = currentImage
        }
        UIGraphicsEndImageContext()
        delegate?.signaturePad(image: drawedImage, data: drawedImage.pngData())
    }
}

fileprivate class Stroke {
    var isPathEmpty: Bool {
        return paths.isEmpty
    }
    
    private(set) var points = [StrokePoint]()
    private var paths = [UIBezierPath]()
    
    func draw(color: UIColor? = nil) {
        paths = []
        var maybePriorPoint: StrokePoint?
        var previousLocation1 = CGPoint()
        
        for point in points {
            guard let _ = maybePriorPoint else {
                maybePriorPoint = point
                previousLocation1 = point.previousLocation
                continue
            }
            
            let previousLocation2 = previousLocation1
            previousLocation1 = point.previousLocation
            let currentLocation = point.location
            
            let midLocation2 = midPoint(previousLocation2, previousLocation1)
            let midLocation1 = midPoint(previousLocation1, currentLocation)
            
            let path = UIBezierPath()
            path.lineCapStyle = .round
            
            path.move(to: midLocation2)
            path.addQuadCurve(to: midLocation1, controlPoint: previousLocation1)
            
            (color ?? point.color).setStroke()
            path.lineWidth = point.magnitude
            path.stroke()
            
            paths.append(path)
            maybePriorPoint = point
        }
    }
    
    func addPoint(touch: UITouch, lineDrawingType: DrawingPadView.LineDrawingType, color: UIColor, in view: UIView) -> CGRect {
        let previousPoint = points.last
        let point = StrokePoint(touch: touch, lineDrawingType: lineDrawingType, color: color, locatedIn: view)
        points.append(point)
        
        let updatedRect = updateRect(point, previousPoint: previousPoint)
        return updatedRect
    }
    
    func updateRect(_ strokePoint: StrokePoint, previousPoint: StrokePoint? = nil) -> CGRect {
        var rect = CGRect(origin: strokePoint.previousLocation, size: .zero)
        var pointMagnitude: CGFloat = strokePoint.magnitude
        
        if let previous = previousPoint {
            pointMagnitude = max(pointMagnitude, previous.magnitude)
            rect = rect.union(CGRect(origin: previous.previousLocation, size: .zero))
        }
        
        let magnitude = -3.0 * pointMagnitude - 2.0
        rect = rect.insetBy(dx: magnitude, dy: magnitude)
        
        return rect
    }
    
    private func midPoint(_ point1: CGPoint, _ point2: CGPoint) -> CGPoint {
        return CGPoint(x: (point1.x + point2.x) / 2, y: (point1.y + point2.y) / 2)
    }
}

fileprivate struct StrokePoint {
    private(set) var type: UITouch.TouchType
    private(set) var color: UIColor
    private(set) var timestamp: TimeInterval
    private(set) var previousLocation: CGPoint
    private(set) var location: CGPoint
    private(set) var maximumPossibleForce: CGFloat
    private(set) var force: CGFloat
    private(set) var lineDrawingType: DrawingPadView.LineDrawingType
    
    var magnitude: CGFloat {
        switch lineDrawingType {
        case .normal(let width):
            return width
        case .interaction(let minWidth, let maxWidth):
            return max((maxWidth * (force / maximumPossibleForce)), minWidth)
        }
    }
    
    init(touch: UITouch, lineDrawingType: DrawingPadView.LineDrawingType, color: UIColor, locatedIn view: UIView) {
        self.type = touch.type
        self.color = color
        
        self.timestamp = touch.timestamp
        self.previousLocation = touch.previousLocation(in: view)
        self.location = touch.location(in: view)
        self.maximumPossibleForce = touch.maximumPossibleForce
        self.force = (type == .pencil || touch.force > 0) ? touch.force : 1.0
        self.lineDrawingType = lineDrawingType
    }
}

//
//  EncodableDataCode.swift
//  KPUI
//
//  Created by Miller on 2018. 4. 26..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import AVKit

public protocol EncodableDataCode: DataCodable {
    var filterName: String { get }
    var filters: [String: Any] { get }
    
    var dataColor: UIColor { get set }
    var backgroundColor: UIColor { get set }
    
    init(message: String, dataColor: UIColor, backgroundColor: UIColor)
}

extension EncodableDataCode {
    var ciImage: CIImage? {
        let filter = CIFilter(name: filterName, parameters: filters)
        return filter?.outputImage
    }
    var cgImage: CGImage? {
        return ciImage?.cgImage
    }
    var uiImage: UIImage? {
        guard let ciImage = ciImage else { return nil }
        return UIImage(ciImage: ciImage)
    }
}

internal extension EncodableDataCode {
    func effectiveValue<ValueType: Comparable>(_ value: ValueType, minimum: ValueType, maximum: ValueType) -> ValueType {
        var newValue = value
        if value <= minimum {
            newValue = minimum
        } else if value > maximum {
            newValue = maximum
        }
        return newValue
    }
}


public protocol DrawableDataCode where Self: EncodableDataCode {
    var strokeColor: UIColor { get }
    var strokeWidth: CGFloat { get }

    func drawPath(adjustScale sx: CGFloat, sy: CGFloat, size: CGSize) -> UIBezierPath;
}

public extension DrawableDataCode {
    func adjustScaling(_ adjustScale: CGFloat, point: CGFloat) -> CGFloat {
        return ceil(point * adjustScale)
    }
}

internal extension DrawableDataCode {
    func strokeWidth(adjustScale: CGFloat) -> CGFloat {
        return adjustScaling(adjustScale, point: strokeWidth)
    }
}

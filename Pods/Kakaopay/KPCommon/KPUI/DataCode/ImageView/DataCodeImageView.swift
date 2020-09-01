//
//  DataCodeImageView.swift
//  KPCore
//
//  Created by Miller on 2018. 4. 23..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import UIKit
import CoreImage

/*
 DataCodeImageView는 DataCode encoing 된 이미지를 노출하는데 사용한다.
 */
open class DataCodeImageView: UIImageView {
    /*
     이미지뷰의 사이즈에 맞게 Data Code Image를 transform scale 하는데,
     사용자에게 보이는 이미지 (적용된 이미지)에 사용된 scale을 저장하는데 사용
     */
    public var adjustedScale: (sx: CGFloat, sy: CGFloat) = (0.0, 0.0)

    /*
     가장 마지막에 setEncdoer를 할 때 사용한 size를 저장할 용도. (더 큰 size만 저장함)
     */
    private var lastSize = CGSize.zero
    public func setEncoder(_ encoder: EncodableDataCode, adjustBiggerSize: Bool = false) {
        guard var encodedImage = encoder.ciImage else {
            adjustedScale = (0.0, 0.0)
            image = nil
            return
        }
        
        // 더 큰 size는 넓이로 계산함.
        lastSize = adjustBiggerSize ? lastSize.biggerExtend(with: frame.size) : frame.size
        
        if let drawable = encoder as? DrawableDataCode {
            adjustedScale = encodedImage.diffScale(size: lastSize)
            encodedImage = encodedImage.scaleBy(sx: adjustedScale.sx, sy: adjustedScale.sy)
            if let drawedImage = drawStrokeIfPossible(paletteImage: encodedImage, encoder: drawable) {
                codeImage = drawedImage
            }
        } else {
            adjustedScale = encodedImage.diffScale(size: lastSize)
            encodedImage = encodedImage.scaleBy(sx: adjustedScale.sx, sy: adjustedScale.sy)
            codeImage = encodedImage
        }
    }
    
    private var codeImage: CIImage? {
        get { return image?.ciImage }
        set {
            guard let newImage = newValue else {
                adjustedScale = (0.0, 0.0)
                image = nil
                return
            }

            image = UIImage(ciImage: newImage)
        }
    }

    private func drawStrokeIfPossible(paletteImage: CIImage, encoder: DrawableDataCode) -> CIImage? {
        let paletteSize = paletteImage.extent.size

        UIGraphicsBeginImageContext(paletteSize)
        let context = UIGraphicsGetCurrentContext()
        context?.setShouldAntialias(false)
        context?.setStrokeColor(encoder.strokeColor.cgColor)
        context?.setLineWidth(encoder.strokeWidth(adjustScale: adjustedScale.sx))
        context?.addPath(encoder.drawPath(adjustScale: adjustedScale.sx, sy: adjustedScale.sy, size: paletteSize).cgPath)
        context?.drawPath(using: .stroke)

        if let drawedImage = UIGraphicsGetImageFromCurrentImageContext(), let drawedCIImage = CIImage(image: drawedImage) {
            UIGraphicsEndImageContext()
            return drawedCIImage.composited(over: paletteImage)
        }
        UIGraphicsEndImageContext()
        return nil
    }
}



/*
 코드 이미지뷰에 얹을 이미지의 position 정보를 담을 struct
 */
public enum AdditionalImagePosition {
    public enum X {
        case center
        case left
        case right
    }
    public enum Y {
        case center
        case top
        case bottom
    }

    case make(x: X, y: Y)
    case center

    fileprivate func internalPosition() -> (x: X, y: Y) {
        switch self {
        case .make(let x, let y):
            return (x: x, y: y)
        case .center:
            return (x: .center, y: .center)
        }
    }
}


/*
 코드 이미지뷰에 얹을 이미지의 정보를 담을 struct
 */
public struct DataCodeAdditionalImage {
    var image: CIImage
    var position: AdditionalImagePosition

    public init?<ImageType>(image: ImageType?, size: CGSize, at position: AdditionalImagePosition = .center) {
        self.init(image: image, size: size, sx: nil, sy: nil, at: position)
    }

    public init?<ImageType>(image: ImageType?, sx: CGFloat, sy: CGFloat, at position: AdditionalImagePosition = .center) {
        self.init(image: image, size: nil, sx: sx, sy: sy, at: position)
    }

    private init?<ImageType>(image: ImageType?, size: CGSize?, sx: CGFloat?, sy: CGFloat?, at position: AdditionalImagePosition = .center) {
        guard image != nil else { return nil }

        var maybeImage: CIImage? = nil
        if let uiImage = image as? UIImage {
            if let candidateCIImage1 = CIImage(image: uiImage) {
                maybeImage = candidateCIImage1
            } else if let candidateCIImage2 = uiImage.ciImage {
                maybeImage = candidateCIImage2
            }
        } else if let ciImage = image as? CIImage {
            maybeImage = ciImage
        }

        guard let mustImage = maybeImage else {
            return nil
        }


        self.position = position
        self.image = mustImage

        if let size = size {
            self.image = mustImage.scaleBy(size: size)
        } else {
            if sx != nil && sy != nil {
                self.image = mustImage.scaleBy(sx: sx!, sy: sy!)
            }
        }
    }
}


/*
 Data Code ImageView에 추가 이미지를 얹을 때 (Composite)
 */
extension DataCodeImageView {
    open func addImage<ImageType>(_ image: ImageType, size: CGSize, at position: AdditionalImagePosition = .center) {
        if let additionalImage = DataCodeAdditionalImage(image: image, size: size, at: position) {
            addImage(additionalImage: additionalImage)
        }
    }
    
    open func addImage<ImageType>(_ image: ImageType, sx: CGFloat, sy: CGFloat, at position: AdditionalImagePosition = .center) {
        if let additionalImage = DataCodeAdditionalImage(image: image, sx: sx, sy: sy, at: position) {
            addImage(additionalImage: additionalImage)
        }
    }

    open func addImages(additionalImages: [DataCodeAdditionalImage]) {
        for additionalImage in additionalImages {
            addImage(additionalImage: additionalImage)
        }
    }

    public func addImage(additionalImage: DataCodeAdditionalImage) {
        guard let originImage = codeImage else { return }

        let sizeOfOriginImageHalf = CGSize(width: originImage.extent.size.width/2, height: originImage.extent.size.height/2)
        let sizeOfAdditionalImageHalf = CGSize(width: additionalImage.image.extent.size.width/2, height: additionalImage.image.extent.size.height/2)
        let centerPositionInOriginImage = CGPoint(x: sizeOfOriginImageHalf.width - sizeOfAdditionalImageHalf.width, y: sizeOfOriginImageHalf.height - sizeOfAdditionalImageHalf.height)

        var movingPosition = CGPoint.zero
        switch additionalImage.position.internalPosition().x {
        case .center:
            movingPosition.x = movingPosition.x + centerPositionInOriginImage.x
            break
        case .left:
            movingPosition.x = 0
            break
        case .right:
            movingPosition.x = originImage.extent.width - additionalImage.image.extent.width
            break
        }
        switch additionalImage.position.internalPosition().y {
        case .center:
            movingPosition.y = movingPosition.y + centerPositionInOriginImage.y
            break
        case .top:
            movingPosition.y = originImage.extent.height - additionalImage.image.extent.height
            break
        case .bottom:
            movingPosition.y = 0
            break
        }

        
        let transformedAdditionalImage = additionalImage.image.transformed(by: CGAffineTransform.init(translationX: movingPosition.x, y: movingPosition.y))
        let compositedImage = transformedAdditionalImage.composited(over: originImage)
        self.image = UIImage(ciImage: compositedImage)
    }
}




fileprivate extension CIImage {
    func diffScale(size: CGSize) -> (sx: CGFloat, sy: CGFloat) {
        let sx: CGFloat = size.width / self.extent.width
        let sy: CGFloat = size.height / self.extent.height

        return (ceil(sx), ceil(sy))
    }

    func scaleBy(size: CGSize) -> CIImage {
        let diff = diffScale(size: size)
        return scaleBy(sx: diff.sx, sy: diff.sy)
    }

    func scaleBy(sx: CGFloat, sy: CGFloat) -> CIImage {
        return self.transformed(by: CGAffineTransform.init(scaleX: sx, y: sy))
    }
}


fileprivate extension CGSize {
    func biggerExtend(with target: CGSize) -> CGSize {
        let leftExtend = width * height
        let rightExtend = target.width * target.height
        return leftExtend > rightExtend ? self : target
    }
}

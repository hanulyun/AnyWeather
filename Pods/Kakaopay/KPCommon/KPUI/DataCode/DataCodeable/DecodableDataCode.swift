//
//  DecodableDataCode.swift
//  KPUI
//
//  Created by Miller on 2018. 4. 26..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import Foundation
import AVKit

public protocol DecodableDataCode: DataCodable {
    var metadata: AVMetadataMachineReadableCodeObject? { get }
    
    init?(metadata: AVMetadataMachineReadableCodeObject)
}

internal extension AVMetadataMachineReadableCodeObject {
    var decoder: DecodableDataCode? {
        switch self.type {
        case ObjectType.ean8: fallthrough
        case ObjectType.ean13: fallthrough
        case ObjectType.upce: fallthrough
        case ObjectType.interleaved2of5: fallthrough
        case ObjectType.code39: fallthrough
        case ObjectType.code39Mod43: fallthrough
        case ObjectType.code93: fallthrough
        case ObjectType.itf14: fallthrough
        case ObjectType.code128:
            return BarDataCode(metadata: self)
        case ObjectType.qr:
            return QRDataCode(metadata: self)
        case ObjectType.dataMatrix:
            return DataMatrixDataCode(metadata: self)
        case ObjectType.aztec:
            return AztecDataCode(metadata: self)
        case ObjectType.pdf417:
            return PDF417DataCode(metadata: self)
        default:
            return nil
        }
    }
}

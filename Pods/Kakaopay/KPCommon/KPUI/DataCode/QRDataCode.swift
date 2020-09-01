//
//  QRDataCode.swift
//  KPUI
//
//  Created by Miller on 2018. 4. 26..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import AVKit

open class QRDataCode: EncodableDataCode, DecodableDataCode, DataRepresentable {
    public var metadata: AVMetadataMachineReadableCodeObject?
    public required init?(metadata: AVMetadataMachineReadableCodeObject) {
        guard let stringValue = metadata.stringValue else {
            return nil
        }
        
        self.message = stringValue
        self.dataColor = .black
        self.backgroundColor = .clear
        self.correctionLevel = .levelH
        
        if let level = errorCorrectionLevel {
            self.correctionLevel = .stringLevel(level: level)
        }
    }
    
    
    
    
    public struct Keys {
        public static let inputMessage = "inputMessage"
        public static let inputCorrectionLevel = "inputCorrectionLevel"
        public static let dataColor = "dataColor"
        public static let backgroundColor = "backgroundColor"
    }

    open class func fromData<ReturnType>(_ data: Data) -> ReturnType? {
        return QRDataCode(data) as? ReturnType
    }
    open func toData() -> Data? {
        var archive: [String : Any] = filters
        archive[Keys.dataColor] = dataColor
        archive[Keys.backgroundColor] = backgroundColor
        return NSKeyedArchiver.archivedData(withRootObject: archive)
    }
    
    
    
    public enum CorrectionLevel {
        case levelL
        case levelM
        case levelQ
        case levelH
        case stringLevel(level: String)
        
        var level: String {
            switch self {
            case .levelL: return "L"
            case .levelM: return "M"
            case .levelQ: return "Q"
            case .levelH: return "H"
            case .stringLevel(let level): return level
            }
        }
    }
    public var correctionLevel: CorrectionLevel
    public var message: String
    
    public var filterName: String = "CIQRCodeGenerator"
    public var filters: [String : Any] {
        return [
            Keys.inputMessage: message.data(using: .isoLatin1)!,
            Keys.inputCorrectionLevel: correctionLevel.level
        ]
    }
    
    public var dataColor: UIColor
    public var backgroundColor: UIColor
    
    
    required public init(message: String) {
        self.message = message
        self.correctionLevel = .levelH
        self.dataColor = .black
        self.backgroundColor = .clear
    }
    
    public required init(message: String, dataColor: UIColor, backgroundColor: UIColor) {
        self.message = message
        self.correctionLevel = .levelH
        self.dataColor = dataColor
        self.backgroundColor = backgroundColor
    }


    public convenience init(_ data: Data) {
        let archive = NSKeyedUnarchiver.unarchiveObject(with: data) as! [String: Any]
        self.init(message: String(data: archive[Keys.inputMessage] as! Data, encoding: .isoLatin1)!,
                  dataColor: archive[Keys.dataColor] as! UIColor,
                  backgroundColor: archive[Keys.backgroundColor] as! UIColor)
        correctionLevel = CorrectionLevel.stringLevel(level: archive[Keys.inputCorrectionLevel] as! String)
    }
}





extension QRDataCode {
    fileprivate var descriptor: CIQRCodeDescriptor? {
        guard let descriptor = metadata?.descriptor as? CIQRCodeDescriptor else {
            return nil
        }
        return descriptor
    }
    
    var errorCorrectedPayload: Data? {
        return descriptor?.errorCorrectedPayload
    }
    var symbolVersion: Int? {
        return descriptor?.symbolVersion
    }
    var maskPattern: UInt8? {
        return descriptor?.maskPattern
    }
    var errorCorrectionLevel: String? {
        guard let level = descriptor?.errorCorrectionLevel else  {
            return nil
        }
        
        switch level {
        case .levelL: return "L"
        case .levelM: return "M"
        case .levelQ: return "Q"
        case .levelH: return "H"
        @unknown default:
            return String(level.rawValue)
        }
    }
}

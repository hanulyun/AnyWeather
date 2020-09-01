//
//  AztecDataCode.swift
//  KPUI
//
//  Created by Miller on 2018. 4. 26..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import AVKit

open class AztecDataCode: EncodableDataCode, DecodableDataCode, DataRepresentable {
    public var metadata: AVMetadataMachineReadableCodeObject?
    public required init?(metadata: AVMetadataMachineReadableCodeObject) {
        guard let message = metadata.stringValue else {
            return nil
        }
        
        self.message = message
        self.dataColor = .black
        self.backgroundColor = .clear
        self.compactStyle = false
        self.correctionLevel = 23.0
        self.layers = 1
        
        if let mustIsStyle = isCompact {
            self.compactStyle = mustIsStyle
        }
        if let mustLayersCount = layerCount {
            self.layers = mustLayersCount
        }
    }

    
    public struct Keys {
        public static let inputMessage = "inputMessage"
        public static let inputCorrectionLevel = "inputCorrectionLevel"
        public static let inputLayers = "inputLayers"
        public static let inputCompactStyle = "inputCompactStyle"
        public static let dataColor = "dataColor"
        public static let backgroundColor = "backgroundColor"
    }
    
    open class func fromData<ReturnType>(_ data: Data) -> ReturnType? {
        return AztecDataCode(data) as? ReturnType
    }
    open func toData() -> Data? {
        var archive: [String : Any] = filters
        archive[Keys.dataColor] = dataColor
        archive[Keys.backgroundColor] = backgroundColor
        return NSKeyedArchiver.archivedData(withRootObject: archive)
    }
    
    public var message: String
    private var internalCorrectionLevel: Float = 23.0
    public var correctionLevel: Float {
        get { return internalCorrectionLevel }
        set { internalCorrectionLevel = effectiveValue(newValue, minimum: 0.0, maximum: 95.0) }
    }
    private var internalLayers: Int = 1
    public var layers: Int {
        get { return internalLayers }
        set { internalLayers = effectiveValue(newValue, minimum: 1, maximum: 32) }
    }
    public var compactStyle: Bool
    
    public var filterName: String = "CIAztecCodeGenerator"
    public var filters: [String : Any] {
        return [
            Keys.inputMessage: message.data(using: .isoLatin1)!,
            Keys.inputCorrectionLevel: correctionLevel,
            Keys.inputLayers: layers,
            Keys.inputCompactStyle: compactStyle
        ]
    }
    
    public var dataColor: UIColor
    public var backgroundColor: UIColor
    
    
    
    required public init(message: String) {
        self.message = message
        self.dataColor = .black
        self.backgroundColor = .clear
        self.compactStyle = false
        self.correctionLevel = 23.0
        self.layers = 1
    }
    
    required public init(message: String, dataColor: UIColor, backgroundColor: UIColor) {
        self.message = message
        self.dataColor = dataColor
        self.backgroundColor = backgroundColor
        self.compactStyle = false
        self.correctionLevel = 23.0
        self.layers = 1
    }
    
    public convenience init(_ data: Data) {
        let archive = NSKeyedUnarchiver.unarchiveObject(with: data) as! [String: Any]
        self.init(message: String(data: archive[Keys.inputMessage] as! Data, encoding: .isoLatin1)!,
                  dataColor: archive[Keys.dataColor] as! UIColor,
                  backgroundColor: archive[Keys.backgroundColor] as! UIColor)
        self.correctionLevel = archive[Keys.inputCorrectionLevel] as! Float
        self.layers = archive[Keys.inputLayers] as! Int
        self.compactStyle = archive[Keys.inputCompactStyle] as! Bool
    }
}




extension AztecDataCode {
    private var descriptor: CIAztecCodeDescriptor? {
        guard let descriptor = metadata?.descriptor as? CIAztecCodeDescriptor else {
            return nil
        }
        return descriptor
    }
    
    var errorCorrectedPayload: Data? {
        return descriptor?.errorCorrectedPayload
    }
    var isCompact: Bool? {
        return descriptor?.isCompact
    }
    var layerCount: Int? {
        return descriptor?.layerCount
    }
    var dataCodewordCount: Int? {
        return descriptor?.dataCodewordCount
    }
}

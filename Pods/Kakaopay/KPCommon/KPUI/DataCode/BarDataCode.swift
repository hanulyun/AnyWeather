//
//  BarDataCode.swift
//  KPUI
//
//  Created by Miller on 2018. 4. 26..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import AVKit

open class BarDataCode: EncodableDataCode, DecodableDataCode, DataRepresentable {
    public var metadata: AVMetadataMachineReadableCodeObject?
    public required init?(metadata: AVMetadataMachineReadableCodeObject) {
        guard let message = metadata.stringValue else {
            return nil
        }
        
        self.message = message
        self.dataColor = .black
        self.backgroundColor = .clear
        self.quietSpace = 7.0
    }
    
    
    public struct Keys {
        public static let inputMessage = "inputMessage"
        public static let inputQuietSpace = "inputQuietSpace"
        public static let dataColor = "dataColor"
        public static let backgroundColor = "backgroundColor"
    }
    
    open class func fromData<ReturnType>(_ data: Data) -> ReturnType? {
        return BarDataCode(data) as? ReturnType
    }
    open func toData() -> Data? {
        var archive: [String : Any] = filters
        archive[Keys.dataColor] = dataColor
        archive[Keys.backgroundColor] = backgroundColor
        return NSKeyedArchiver.archivedData(withRootObject: archive)
    }
    
    
    
    private var internalQuietSpace: Float = 0.0
    var quietSpace: Float {
        get { return internalQuietSpace }
        set { internalQuietSpace = effectiveValue(newValue, minimum: 0.0, maximum: 20.0) }
    }
    public var message: String
    
    public var filterName: String = "CICode128BarcodeGenerator"
    public var filters: [String: Any] {
        return [
            Keys.inputMessage: message.data(using: .ascii)!,
            Keys.inputQuietSpace: quietSpace
        ]
    }
    
    public var dataColor: UIColor
    public var backgroundColor: UIColor
    
    
    
    required public init(message: String) {
        self.message = message
        self.dataColor = .black
        self.backgroundColor = .clear
        self.quietSpace = 0.0
    }
    
    public required init(message: String, dataColor: UIColor, backgroundColor: UIColor) {
        self.message = message
        self.dataColor = dataColor
        self.backgroundColor = backgroundColor
        self.quietSpace = 0.0
    }

    public convenience init(_ data: Data) {
        let archive = NSKeyedUnarchiver.unarchiveObject(with: data) as! [String: Any]
        self.init(message: String(data: archive[Keys.inputMessage] as! Data, encoding: .isoLatin1)!,
                  dataColor: archive[Keys.dataColor] as! UIColor,
                  backgroundColor: archive[Keys.backgroundColor] as! UIColor)
        self.quietSpace = archive[Keys.inputQuietSpace] as! Float
    }
}

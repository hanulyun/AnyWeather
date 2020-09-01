//
//  PDF417DataCode.swift
//  KPUI
//
//  Created by Miller on 2018. 4. 26..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import AVKit

open class PDF417DataCode: EncodableDataCode, DecodableDataCode, DataRepresentable {
    public var metadata: AVMetadataMachineReadableCodeObject?
    public required init?(metadata: AVMetadataMachineReadableCodeObject) {
        guard let message = metadata.stringValue else {
            return nil
        }
        
        self.message = message
        self.dataColor = .black
        self.backgroundColor = .clear
        self.compactionMode = .automatic
        self.compactStyle = false
        self.alwaysSpecifyCompaction = 0.0
        self.correctionLevel = 0.0
        self.minSize = CGSize(width: 56.0, height: 13.0)
        self.maxSize = CGSize(width: 56.0, height: 13.0)
        self.dataColumns = 1
        self.rows = 3
        self.preferredAspectRatio = 0.0
    }
    
    
    
    public struct Keys {
        public static let inputMessage = "inputMessage"
        public static let inputMinWidth = "inputMinWidth"
        public static let inputMaxWidth = "inputMaxWidth"
        public static let inputMinHeight = "inputMinHeight"
        public static let inputMaxHeight = "inputMaxHeight"
        public static let inputDataColumns = "inputDataColumns"
        public static let inputRows = "inputRows"
        public static let inputPreferredAspectRatio = "inputPreferredAspectRatio"
        public static let inputCompactionMode = "inputCompactionMode"
        public static let inputCompactStyle = "inputCompactStyle"
        public static let inputCorrectionLevel = "inputCorrectionLevel"
        public static let inputAlwaysSpecifyCompaction = "inputAlwaysSpecifyCompaction"
        public static let dataColor = "dataColor"
        public static let backgroundColor = "backgroundColor"
    }
    
    open class func fromData<ReturnType>(_ data: Data) -> ReturnType? {
        return PDF417DataCode(data) as? ReturnType
    }
    open func toData() -> Data? {
        var archive: [String: Any] = filters
        archive[Keys.dataColor] = dataColor
        archive[Keys.backgroundColor] = backgroundColor
        return NSKeyedArchiver.archivedData(withRootObject: archive)
    }
    
    
    
    private var internalCorrectionLevel: Float = 0.0
    public var correctionLevel: Float {
        get { return internalCorrectionLevel }
        set { internalCorrectionLevel = effectiveValue(newValue, minimum: 0.0, maximum: 8.0) }
    }
    private var internalMinSize: CGSize = CGSize(width: 56.0, height: 13.0)
    public var minSize: CGSize {
        get { return internalMinSize }
        set {
            return internalMinSize = CGSize(width: effectiveValue(newValue.width, minimum: 56.0, maximum: 583.0),
                                            height: effectiveValue(newValue.height, minimum: 13.0, maximum: 283.0))
        }
    }
    private var internalMaxSize: CGSize = CGSize(width: 56.0, height: 13.0)
    public var maxSize: CGSize {
        get { return internalMinSize }
        set {
            return internalMinSize = CGSize(width: effectiveValue(newValue.width, minimum: 56.0, maximum: 583.0),
                                            height: effectiveValue(newValue.height, minimum: 13.0, maximum: 283.0))
        }
    }
    private var internalDataColumns: Int = 1
    public var dataColumns: Int {
        get { return internalDataColumns }
        set { internalDataColumns = effectiveValue(newValue, minimum: 1, maximum: 30) }
    }
    private var internalRows: Int = 3
    public var rows: Int {
        get { return internalRows }
        set { internalRows = effectiveValue(newValue, minimum: 3, maximum: 90)}
    }
    private var internalPreferredAspectRatio: Float = 0.0
    public var preferredAspectRatio: Float {
        get { return internalPreferredAspectRatio }
        set { internalPreferredAspectRatio = effectiveValue(newValue, minimum: 0.0, maximum: 9223372036854775808.00)}
    }
    
    public enum PDF417CompactionMode: Int {
        case automatic = 0
        case numeric = 1
        case text = 2
        case byte = 3
    }
    public var compactionMode: PDF417CompactionMode
    public var compactStyle: Bool
    private var internalAlwaysSpecifyCompaction: Float = 0.0
    public var alwaysSpecifyCompaction: Float {
        get { return internalAlwaysSpecifyCompaction }
        set { internalAlwaysSpecifyCompaction = effectiveValue(newValue, minimum: -Float.greatestFiniteMagnitude , maximum: Float.greatestFiniteMagnitude) }
    }
    
    public var message: String
    
    public var filterName: String = "CIPDF417BarcodeGenerator"
    public var filters: [String : Any] {
        return [
            Keys.inputMessage: message.data(using: .isoLatin1)!,
            Keys.inputMinWidth: minSize.width,
            Keys.inputMaxWidth: maxSize.width,
            Keys.inputMinHeight: minSize.height,
            Keys.inputMaxHeight: maxSize.height,
            Keys.inputDataColumns: dataColumns,
            Keys.inputRows: rows,
            Keys.inputPreferredAspectRatio: preferredAspectRatio,
            Keys.inputCompactionMode: compactionMode.rawValue,
            Keys.inputCompactStyle: compactStyle,
            Keys.inputCorrectionLevel: correctionLevel,
            Keys.inputAlwaysSpecifyCompaction: alwaysSpecifyCompaction,
        ]
    }
    
    public var dataColor: UIColor
    public var backgroundColor: UIColor
    
    
    
    required public init(message: String) {
        self.message = message
        self.dataColor = .black
        self.backgroundColor = .clear
        self.compactionMode = .automatic
        self.compactStyle = false
        self.alwaysSpecifyCompaction = 0.0
        self.correctionLevel = 0.0
        self.minSize = CGSize(width: 56.0, height: 13.0)
        self.maxSize = CGSize(width: 56.0, height: 13.0)
        self.dataColumns = 1
        self.rows = 3
        self.preferredAspectRatio = 0.0
    }
    
    required public init(message: String, dataColor: UIColor, backgroundColor: UIColor) {
        self.message = message
        self.dataColor = dataColor
        self.backgroundColor = backgroundColor
        self.compactionMode = .automatic
        self.compactStyle = false
        self.alwaysSpecifyCompaction = 0.0
        self.correctionLevel = 0.0
        self.minSize = CGSize(width: 56.0, height: 13.0)
        self.maxSize = CGSize(width: 56.0, height: 13.0)
        self.dataColumns = 1
        self.rows = 3
        self.preferredAspectRatio = 0.0
    }
    
    public convenience init(_ data: Data) {
        let archive = NSKeyedUnarchiver.unarchiveObject(with: data) as! [String: Any]
        self.init(message: String(data: archive[Keys.inputMessage] as! Data, encoding: .isoLatin1)!,
                  dataColor: archive[Keys.dataColor] as! UIColor,
                  backgroundColor: archive[Keys.backgroundColor] as! UIColor)
        self.correctionLevel = archive[Keys.inputCorrectionLevel] as! Float
        self.minSize = CGSize(width: archive[Keys.inputMinWidth] as! CGFloat, height: archive[Keys.inputMinHeight] as! CGFloat)
        self.maxSize = CGSize(width: archive[Keys.inputMaxWidth] as! CGFloat, height: archive[Keys.inputMaxHeight] as! CGFloat)
        self.dataColumns = archive[Keys.inputDataColumns] as! Int
        self.rows = archive[Keys.inputRows] as! Int
        self.preferredAspectRatio = archive[Keys.inputPreferredAspectRatio] as! Float
        self.compactionMode = PDF417CompactionMode(rawValue: archive[Keys.inputCompactionMode] as! Int)!
        self.compactStyle = archive[Keys.inputCompactStyle] as! Bool
        self.alwaysSpecifyCompaction = archive[Keys.inputAlwaysSpecifyCompaction] as! Float
        self.dataColor = archive[Keys.dataColor] as! UIColor
        self.backgroundColor = archive[Keys.backgroundColor] as! UIColor
    }
}





extension PDF417DataCode {
    private var descriptor: CIPDF417CodeDescriptor? {
        guard let descriptor = self.metadata?.descriptor as? CIPDF417CodeDescriptor else {
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
    var rowCount: Int? {
        return descriptor?.rowCount
    }
    var columnCount: Int? {
        return descriptor?.columnCount
    }
}

//
//  DataMatrixDataCode.swift
//  KPUI
//
//  Created by Miller on 2018. 4. 26..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import AVKit

open class DataMatrixDataCode: DecodableDataCode {
    public var message: String
    public var metadata: AVMetadataMachineReadableCodeObject?
    public required init?(metadata: AVMetadataMachineReadableCodeObject) {
        guard let stringValue = metadata.stringValue else {
            return nil
        }
        
        self.message = stringValue
    }
    
    public required init(message: String) {
        fatalError("")
    }
}

extension DataMatrixDataCode {
    private var descriptor: CIDataMatrixCodeDescriptor? {
        guard let descriptor = metadata?.descriptor as? CIDataMatrixCodeDescriptor else {
            return nil
        }
        return descriptor
    }
    
    var errorCorrectedPayload: Data? {
        return descriptor?.errorCorrectedPayload
    }
    var rowCount: Int? {
        return descriptor?.rowCount
    }
    var columnCount: Int? {
        return descriptor?.columnCount
    }
    var dataCodewordCount: Int? {
        return descriptor?.eccVersion.rawValue
    }
}


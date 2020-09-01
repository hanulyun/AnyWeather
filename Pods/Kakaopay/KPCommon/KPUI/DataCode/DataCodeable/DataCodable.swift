//
//  DataCodable.swift
//  KPUI
//
//  Created by Miller on 2018. 4. 26..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import Foundation

public protocol DataCodable {
    var message: String { get }
    init(message: String)
}

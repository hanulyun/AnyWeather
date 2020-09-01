//
//  HTTPURLResponse+HTTPClient.swift
//  KPCore
//
//  Created by henry on 2018. 1. 26..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import UIKit

extension HTTPURLResponse {
    
    public func isValidateStatusCode() -> Bool {
        return (200..<300).contains(statusCode)
    }
}


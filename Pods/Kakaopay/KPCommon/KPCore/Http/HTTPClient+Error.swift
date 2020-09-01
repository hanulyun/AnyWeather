//
//  HTTPClient+Error.swift
//  KPCore
//
//  Created by henry on 2018. 4. 26..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

extension HTTPClient {
    
    public enum HTTPClientResponseError: Error {
        case invalidStatusCode
    }
}

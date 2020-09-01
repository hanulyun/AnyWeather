//
//  DataRepresentable.swift
//  KPCore
//
//  Created by henry on 2018. 3. 2..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import UIKit

// data 로 변환할 필요가 있는 concrete class 들에 사용되는 interface 입니다.
public protocol DataRepresentable {
    
    func toData() -> Data?
    static func fromData<ReturnType>(_ data: Data) -> ReturnType?
}

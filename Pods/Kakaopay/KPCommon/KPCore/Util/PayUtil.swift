//
//  KPUtil.swift
//  KPCommon
//
//  Created by Freddy on 11/01/2019.
//  Copyright © 2019 kakaopay. All rights reserved.
//

import Foundation

// Swift 😊
public struct PayUtil { }

// Objective-C 💩
@objcMembers
public final class NSPayUtil: NSObject {
    // Device
    @objc public static var deviceIsLocked = PayUtil.Device.isLocked
    
    // Usim
    public static var usimMCC = PayUtil.Usim.mcc
    public static var usimMNC = PayUtil.Usim.mnc
}

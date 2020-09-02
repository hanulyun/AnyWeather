//
//  Main.swift
//  AnyWeather
//
//  Created by joey.con on 2020/09/01.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import Kakaopay

protocol MainNamespace {
    typealias API = Main.API
    typealias Model = Main.Model
}

struct Main: Namespace {
    static func initialize() { }
    struct API { typealias Model = Main.Model }
    struct Model { }
    struct Action {
        typealias Model = Main.Model
        typealias API = Main.API
    }
    
    static let degSymbol: String = "°"
}

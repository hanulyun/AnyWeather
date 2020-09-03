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
    typealias Action = Main.Action
}

struct Main: Namespace {
    static func initialize() { }
    struct API { typealias Model = Main.Model }
    struct Model { typealias LocalWeather = CoreWeather }
    struct Action {
        typealias Model = Main.Model
        typealias API = Main.API
    }
    
    static let degSymbol: String = "°"
    static let entityName: String = "CoreWeather"
    static let location: LocationClient = LocationClient()
}

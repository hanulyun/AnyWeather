//
//  List.swift
//  AnyWeather
//
//  Created by joey.con on 2020/09/03.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import Kakaopay

protocol ListNamespace {
    typealias API = List.API
    typealias Model = List.Model
    typealias Action = List.Action
}

struct List: Namespace {
    static func initialize() { }
    struct API { typealias Model = List.Model }
    struct Model { typealias Weather = Main.Model.Weather }
    struct Action { }
    
    static let degSymbol: String = "°"
}

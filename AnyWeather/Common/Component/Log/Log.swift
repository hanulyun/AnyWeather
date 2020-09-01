//
//  Log.swift
//  AnyWeather
//
//  Created by hanulyun-tera on 2020/06/04.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import Foundation

class Log {
    class func debug<T>(_ object: T?, file: String = #file, line: Int = #line,
                    funcName: String = #function) {
        #if DEBUG
        let fileNames = file.components(separatedBy: ["/", "."])
        let fileName = fileNames[fileNames.count - 2]
        if let object = object {
            print("\(fileName).\(funcName): line\(line) - ☀️ \(object)")
        } else {
            print("\(fileName).\(funcName): line\(line) - ☀️ nil")
        }
        #endif
    }
}

//
//  KPCore+Pay.swift
//  KPCore
//
//  Created by Miller on 2018. 7. 31..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import Foundation

/*
 swift struct을 제외한 웬만한 애들은 모두 PayCompatible로 묶을 수 있음. 이건 논의 해보는게 좋을듯.
 굳이 사용안하는데 확장시켜둘 필요가 있나..?! 아님 편리하니깐??
 */
//extension NSObject: PayCompatible { }

extension String: PayCompatible { }
extension Bool: PayCompatible { }
extension Int: PayCompatible { }
extension Data: PayCompatible { }
extension Date: PayCompatible { }
extension URL: PayCompatible { }

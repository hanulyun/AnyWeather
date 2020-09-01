//
//  HttpClient+ResponseError.swift
//  AnyWeather
//
//  Created by joey.con on 2020/09/01.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import Kakaopay

protocol PayError : Error {
    func errorInfo() -> (code: String?, title: String?, subtitle: String?, message: String?)?
    var localizedDescription: String { get }
}

extension PayError {
    var localizedDescription: String {
        return errorInfo()?.message ?? ""
    }
}

extension HTTPClient {
    
    enum ResponseError: PayError, CustomNSError {
        case invalidStatusCode(code: String, title: String?, subtitle: String?, message: String)
        case unhandled(code: String? = nil, message: String? = nil, error: Error?, statusCode: Int = -1)

        func errorInfo() -> (code: String?, title: String?, subtitle: String?, message: String?)? {
            switch self {
            case .invalidStatusCode(let code, let title, let subtitle, let message):
                return (code, title, subtitle, message)
            case .unhandled(_, let message, let error, let statusCode):
                if isNetworkFail {
                    return ("\(statusCode)", nil, nil, message: "네트워크 연결상태가 좋지 않습니다.\n잠시 후 다시 시도해주세요.")
                } else {
                    return ("\(statusCode)", nil, nil, message: message ?? error?.localizedDescription ?? "일시적인 오류가 발생했습니다.\n잠시 후 다시 시도해주세요.")
                }
            }
        }

        var isHandled: Bool { // 페이 서버 오류인지 판단.
            switch self {
            case .invalidStatusCode(_, _, _, _):
                return true
            default:
                return false
            }
        }

        var isNetworkFail: Bool {
            switch self {
            case .unhandled(_, _, let maybeError, _):
                guard let error = maybeError else { return false }
                return (error as NSError).domain == NSURLErrorDomain
            default:
                return false
            }
        }

        var debugMessage: String {
            switch self {
            case .invalidStatusCode(let code, _, _, let message):
                return "\(code) \(message)"
            case .unhandled(_, _, let error, let code):
                return "\(code) \(error?.localizedDescription ?? "")"
            }
        }
    }
    
    enum SessionError: Error {
        case invalidSession
        case invalidStatusCode
        case unhandled
        
        var localizedDescription: String {
            switch self {
            case .invalidSession: return "올바르지 않은 접근"
            case .invalidStatusCode: return "서버 상태 이상"
            case .unhandled: return "알 수없는 오류"
            }
        }
    }
}

//
//  HttpManager.swift
//  KPCore
//
//  Created by henry on 2018. 1. 23..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

public typealias JSONDictionary = Dictionary<String, Any>
public typealias JSONArray = Array<Any>

open class HTTPClient {
    public enum Method: String {
        case mock /* for mocking test */
        case get     = "GET"
        case head    = "HEAD"
        case post    = "POST"
        case put     = "PUT"
        case delete  = "DELETE"
    }
    
    open class var shared: HTTPClient {
        struct Instance {
            static let instance = HTTPClient(sessionConfiguration: URLSessionConfiguration.default)
        }
        return Instance.instance
    }

    public init() {
        self.session = URLSession(configuration: URLSessionConfiguration.default, delegate: sessionDelegator, delegateQueue: OperationQueue.main)
    }
    
    public init(sessionConfiguration: URLSessionConfiguration, on delegateQueue: OperationQueue? = OperationQueue.main) {
        self.session = URLSession(configuration: sessionConfiguration, delegate: sessionDelegator, delegateQueue: delegateQueue)
    }
    
    private let sessionDelegator: SessionDelegator = SessionDelegator()

    public let session: URLSession!
    public var startImmediately: Bool = true
    public var logLevel: LogLevel = .none
    public var decoder = HTTPClient.Decoder()

    // MARK: Provider
    
    /*
     requestProvider 를 설정하면, URLRequest 생성 로직이 해당 provider 함수로 대체됩니다.
     request 과정을 customize 하고자 하는 경우 사용할 수 있습니다.
     */
    public var requestProvider: ((_ urlString: String, _ method: Method, _ headers: [String: String]?, _ parameters: [String: Any]?, _ parameterEncoding: URLRequest.ParameterEncoding?) -> URLRequest?)? = nil
    
    /*
     additionalRequestHeaderProvider 를 설정하면, request 호출 직전 추가적인 headers 를 설정할 수 있습니다.
     해당 함수는 requestProvider 설정 여부와 상관없이 호출되며 urlRequest 객체가 생성된 이후 호출됨이 보장 됩니다.
     */
    public var additionalRequestHeaderProvider: (() -> [String: String]?)? = nil
    
    /*
     pinCertificatesProvider 를 설정하면, 서버로 부터 authentication challege 발생시 SSL pinning 을 사용합니다.
     */
    public var pinCertificatesProvider: (() -> [SecCertificate])? = nil {
        didSet {
            sessionDelegator.pinCertificatesProvider = pinCertificatesProvider
        }
    }
    
    /*
     responseValidateProvider 를 설정하면, response data 에 대한 검증 로직이 해당 provider 함수로 대체됩니다.
     response validation 과정을 customize 하고자 하는 경우 사용할 수 있습니다.
     */
    public var responseValidateProvider: ((Data?, URLResponse?, Error?) throws -> Void)? = nil
    
    // MARK: Delegate
    public var requestWillStart: ((URLRequest, [String: Any]?, URLRequest.ParameterEncoding?) -> Void)? = nil // request, params(key/value), encoding
    public var requestDidEnd: ((URLRequest, Response, TimeInterval) -> Void)? = nil // request, response, duration
    
    // MARK: Open Functions
    open func makeRequest(urlString: String, method: Method,
                          headers: [String: String]?,
                          parameters: [String: Any]?, parameterEncoding: URLRequest.ParameterEncoding?) -> URLRequest? {
        // make url request.
        var maybeUrlRequest: URLRequest? = nil
        if let requestProvider = self.requestProvider {
            maybeUrlRequest = requestProvider(urlString, method, headers, parameters, parameterEncoding)
        } else if let url = URL(string: urlString) {
            maybeUrlRequest = URLRequest(url: url, method: method.rawValue, cachePolicy: session.configuration.requestCachePolicy,
                                         timeoutInterval: session.configuration.timeoutIntervalForRequest,
                                         headers: headers,
                                         parameters: parameters, parameterEncoding: parameterEncoding)
        }
        
        guard var urlRequest = maybeUrlRequest else {
            return nil
        }
        
        // add additional header.li
        if let additionalRequestHeaderProvider = self.additionalRequestHeaderProvider, let additionalRequestHeaders = additionalRequestHeaderProvider() {
            for (headerField, headerValue) in additionalRequestHeaders {
                urlRequest.setValue(headerValue, forHTTPHeaderField: headerField)
            }
        }
        
        requestWillStart?(urlRequest, parameters, parameterEncoding)
        if logLevel != .none { // print built-in log message if possible
            printRequestLog(urlRequest, parameters, parameterEncoding)
        }
        return urlRequest
    }
    
    open func handleCompletion<ResponseData>(urlRequest: URLRequest, response: Response, result: ResponseData?, method: Method, duration: TimeInterval, completionHandler: @escaping (ResponseData?, Error?) -> Void) {
        if method == .mock {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                completionHandler(result, response.maybeError)
            }
            return
        }
        
        requestDidEnd?(urlRequest, response, duration)
        if logLevel != .none { // print built-in log message if possible
            printResponseLog(response, result, duration)
        }
        completionHandler(result, response.maybeError)
    }
}

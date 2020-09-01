//
//  HTTPClientResponse.swift
//  KPCore
//
//  Created by henry on 2018. 7. 25..
//  Copyright © 2018년 kakaopay. All rights reserved.
//

import Foundation

extension HTTPClient {
    
    public class Response {
        public var maybeData: Data?
        public var maybeResponse: URLResponse?
        public var maybeError: Error?
        
        init(_ maybeData: Data?, _ maybeResponse: URLResponse?, _ maybeError: Error?) {
            self.maybeData = maybeData
            self.maybeResponse = maybeResponse
            self.maybeError = maybeError
        }
    }
    
    public class MockResponse: Response {
        override init(_ maybeData: Data?, _ maybeResponse: URLResponse?, _ maybeError: Error?) {
            super.init(maybeData, maybeResponse, maybeError)
            
            var mockHttpResponse: HTTPURLResponse? = HTTPURLResponse(url: (maybeResponse?.url)!, statusCode: 200, httpVersion: "HTTP/2.0", headerFields: nil)
            do {
                if try JSONSerialization.jsonObject(with: maybeData!, options: .allowFragments) as? JSONArray != nil {
                    mockHttpResponse = HTTPURLResponse(url: (mockHttpResponse?.url)!, statusCode: 200, httpVersion: "HTTP/2.0", headerFields: nil)
                } else {
                    if let jsonDictionary = try JSONSerialization.jsonObject(with: maybeData!, options: .allowFragments) as? JSONDictionary {
                        if let error = jsonDictionary["error"] as? JSONDictionary {
                            if let ratio = error["error_ratio"] as? Double {
                                let rand = Double(arc4random_uniform(100)) / 100.0
                                if rand < ratio || ratio == 1.0 {
                                    mockHttpResponse = HTTPURLResponse(url: (maybeResponse?.url)!, statusCode: error["status"] as! Int, httpVersion: "HTTP/2.0", headerFields: nil)
                                    self.maybeData = error.toData()
                                } else {
                                    mockHttpResponse = HTTPURLResponse(url: (maybeResponse?.url)!, statusCode: 200, httpVersion: "HTTP/2.0", headerFields: nil)
                                }
                            }
                        }
                    }
                }
            } catch let responseError {
                self.maybeError = responseError
            }
            self.maybeResponse = mockHttpResponse
        }
    }
}

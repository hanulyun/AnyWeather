//
//  APIManagerTests.swift
//  AnyWeatherTests
//
//  Created by Hanul Yun on 2020/06/10.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import XCTest
import Promises
@testable import AnyWeather

class APIManagerTests: XCTestCase {
    
    let apiManager: APIManager = APIManager.shared
    let lat: Double = 37.57
    let lon: Double = 126.98
    let url: String = Urls.oneCall
    var param: [String: Any] {
        return [ParamKey.lat.rawValue: lat.description, ParamKey.lon.rawValue: lon.description]
    }
    
    func testUrlParameters() {
        let mockURLSession: MockURLSession = MockURLSession(data: nil, urlResponse: nil, error: nil)
        apiManager.session = mockURLSession
    
        apiManager.setComponentUrl(url, param: param).then { url in
            XCTAssertEqual(url.query?.contains(ParamKey.lat.rawValue), true)
            XCTAssertEqual(url.query?.contains(ParamKey.lon.rawValue), true)
        }
    }
    
    func testRequestAndDecoderModel() {
        let jsonData = "{\"id\": 1, \"city\": \"서울특별시\"}".data(using: .utf8)
        let mockResponse: HTTPURLResponse? = HTTPURLResponse(url: URL(string: url)!, statusCode: 200,
                                                             httpVersion: nil, headerFields: nil)
        let mockURLSession: MockURLSession = MockURLSession(data: jsonData,
                                                            urlResponse: mockResponse, error: nil)
        apiManager.session = mockURLSession
        
        let modelExpect: XCTestExpectation = expectation(description: "mockModel")
        var mockModel: MockModel?
        
        let param: [String: Any] = [
            ParamKey.lat.rawValue: "37.57",
            ParamKey.lon.rawValue: "126.98",
        ]
        
        apiManager.request(MockModel.self, url: url, param: param).then { model in
            mockModel = model
            modelExpect.fulfill()
        }

        waitForExpectations(timeout: 1) { (error) in
          XCTAssertNotNil(mockModel)
        }
    }
    
    func testRequestDataEmptyError() {
        let mockResponse: HTTPURLResponse? = HTTPURLResponse(url: URL(string: url)!, statusCode: 200,
                                                             httpVersion: nil, headerFields: nil)
        let mockURLSession: MockURLSession = MockURLSession(data: nil,
                                                            urlResponse: mockResponse, error: nil)
        apiManager.session = mockURLSession
        
        let errorExpect: XCTestExpectation = expectation(description: "noDataError")
        var errorRes: Error?
        
        apiManager.request(MockModel.self, url: url, param: param).catch { error in
            errorRes = error
            errorExpect.fulfill()
        }
        
        waitForExpectations(timeout: 1) { error in
            XCTAssertNotNil(errorRes)
            XCTAssertEqual(errorRes as? SessionError, SessionError.noData)
        }
    }
    
    func testRequestInvalidJsonError() {
        let jsonData = "[{\"test\"}]".data(using: .utf8)
        let mockResponse: HTTPURLResponse? = HTTPURLResponse(url: URL(string: url)!, statusCode: 200,
                                                             httpVersion: nil, headerFields: nil)
        let mockURLSession: MockURLSession = MockURLSession(data: jsonData,
                                                            urlResponse: mockResponse, error: nil)
        apiManager.session = mockURLSession
        
        let errorExpect: XCTestExpectation = expectation(description: "error")
        var errorRes: Error?
        
        apiManager.request(MockModel.self, url: url, param: param).catch { error in
            errorRes = error
            errorExpect.fulfill()
        }

        waitForExpectations(timeout: 1) { (error) in
            XCTAssertNotNil(errorRes)
            XCTAssertEqual(errorRes as? SessionError, SessionError.failedToParse)
        }
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

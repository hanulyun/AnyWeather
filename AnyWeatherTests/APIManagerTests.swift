//
//  APIManagerTests.swift
//  AnyWeatherTests
//
//  Created by Hanul Yun on 2020/06/10.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import XCTest
@testable import AnyWeather

class APIManagerTests: XCTestCase {
    
    let apiManager = APIManager()
    let lat: Double = 37.57
    let lon: Double = 126.98
    let url: String = Urls.oneCall
    var param: [String: Any] {
        return [ParamKey.lat.rawValue: lat.description, ParamKey.lon.rawValue: lon.description]
    }
    
    func testUrlParameters() {
        let mockURLSession = MockURLSession(data: nil, urlResponse: nil, error: nil)
        apiManager.session = mockURLSession
    
        apiManager.request(MockModel.self, url: url, param: param) { (_, _) in }
  
        XCTAssertEqual(mockURLSession.cachedUrl?.query?.contains(ParamKey.lat.rawValue), true)
        XCTAssertEqual(mockURLSession.cachedUrl?.query?.contains(ParamKey.lon.rawValue), true)
    }
    
    func testRequestAndDecoderModel() {
        let jsonData = "{\"id\": 1, \"city\": \"서울특별시\"}".data(using: .utf8)
        let mockURLSession = MockURLSession(data: jsonData, urlResponse: nil, error: nil)
        apiManager.session = mockURLSession
        
        let modelExpect = expectation(description: "mockModel")
        var mockModel: MockModel?
        
        let param: [String: Any] = [
            ParamKey.lat.rawValue: "37.57",
            ParamKey.lon.rawValue: "126.98",
        ]
        
        apiManager.request(MockModel.self, url: url, param: param) { (model, _) in
            mockModel = model
            modelExpect.fulfill()
        }
        
        waitForExpectations(timeout: 1) { (error) in
          XCTAssertNotNil(mockModel)
        }
    }
    
    func testRequestReturnError() {
        let inputError: NSError = NSError(domain: "error", code: 777, userInfo: nil)
        let mockURLSession = MockURLSession(data: nil, urlResponse: nil, error: inputError)
        apiManager.session = mockURLSession
        
        let errorExpect: XCTestExpectation = expectation(description: "error")
        var errorRes: Error?
        
        apiManager.request(MockModel.self, url: url, param: param) { (_, error) in
            errorRes = error
            errorExpect.fulfill()
        }
        
        waitForExpectations(timeout: 1) { error in
            XCTAssertNotNil(errorRes)
        }
    }
    
    func testRequestDataEmptyError() {
        let mockURLSession = MockURLSession(data: nil, urlResponse: nil, error: nil)
        apiManager.session = mockURLSession
        
        let errorExpect: XCTestExpectation = expectation(description: "error")
        var errorRes: Error?
        
        apiManager.request(MockModel.self, url: url, param: param) { (_, error) in
            errorRes = error
            errorExpect.fulfill()
        }
        
        waitForExpectations(timeout: 1) { (error) in
            XCTAssertNotNil(errorRes)
        }
    }
    
    func testRequestInvalidJsonError() {
        let jsonData = "[{\"test\"}]".data(using: .utf8)
        let mockURLSession = MockURLSession(data: jsonData, urlResponse: nil, error: nil)
        apiManager.session = mockURLSession
        
        let errorExpect: XCTestExpectation = expectation(description: "error")
        var errorRes: Error?
        
        apiManager.request(MockModel.self, url: url, param: param) { (_, error) in
            errorRes = error
            errorExpect.fulfill()
        }
        
        waitForExpectations(timeout: 1) { (error) in
            XCTAssertNotNil(errorRes)
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

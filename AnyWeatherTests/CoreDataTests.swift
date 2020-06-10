//
//  CoreDataTests.swift
//  AnyWeatherTests
//
//  Created by Hanul Yun on 2020/06/10.
//  Copyright © 2020 hanulyun. All rights reserved.
//

import XCTest
import CoreData
@testable import AnyWeather

class CoreDataTests: XCTestCase {
    
    var coreDataManager: CoreDataManager!
    
    override func setUp() {
        coreDataManager = CoreDataManager.shared
    }
    
    override func tearDown() {
        
    }
    
    func testInitCoreDataManager() {
        let instance: CoreDataManager = CoreDataManager.shared
        XCTAssertNotNil(instance)
    }
    
    func testCoreDataStackInit() {
        let coreDataStack = CoreDataManager.shared.persistentContainer
        XCTAssertNotNil(coreDataStack)
    }
    
    // 모두 지우고 테스트 시작
    func testDeletAllData() {
        for index in 0..<4 {
            coreDataManager.deleteData(filterId: index) { (isDeleted, type) in
                XCTAssertEqual(isDeleted, true)
            }
        }
    }
    
    func testSaveAndGetData() {
        let testCases: [(id: Int, city: String, lat: Double, lon: Double)] = [
            (0, "GPS", 0, 0),
            (1, "로컬1", 11.11, 11.11),
            (2, "로컬2", 22.22, 22.22),
            (3, "로컬3", 33.33, 33.33)
        ]
        
        for (index, test) in testCases.enumerated() {
            coreDataManager.saveData(id: test.id, city: test.city, lat: test.lat, lon: test.lon) { isSaved in
                XCTAssertEqual(isSaved, true)
                let allDatas: [Weather] = self.coreDataManager.getData()
                XCTAssertEqual(allDatas.count, index + 1)
            }
        }
    }
    
    func testDeleteData() {
        // 값이 있는 경우
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.coreDataManager.deleteData(filterId: 2) { (isDeleted, type) in
                XCTAssertEqual(isDeleted, true)
                XCTAssertEqual(type, .success)
            }
            
            self.coreDataManager.deleteData(filterId: 7) { (isDeleted, type) in
                XCTAssertEqual(isDeleted, true)
                XCTAssertEqual(type, .noMatch)
            }
        }
    }
    
    func testUpdateDataList() {
        // 3번째의 로컬3을 1번째로 옮긴 후 리스트 갱신 테스트
        let weatherModels: [WeatherModel] = [
            WeatherModel(id: 3, city: "로컬3", isGps: true, lat: 11, lon: 11, current: nil, hourly: nil, daily: nil),
            WeatherModel(id: 1, city: "로컬1", isGps: false, lat: 22, lon: 22, current: nil, hourly: nil, daily: nil),
            WeatherModel(id: 2, city: "로컬2", isGps: false, lat: 33, lon: 33, current: nil, hourly: nil, daily: nil)
        ]
        
        coreDataManager.editDataList(data: weatherModels, onGps: true) { isEdited in
            XCTAssertEqual(isEdited, true)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let allDatas: [Weather] = self.coreDataManager.getData()
            XCTAssertEqual(allDatas.first?.id, 1)
            XCTAssertEqual(allDatas.first?.city, "로컬3")
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

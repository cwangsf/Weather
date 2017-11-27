

import XCTest

@testable import Weather

class WeatherTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testgetUSCityList() {
        DataManager.usCityList()
    }
    func testCityNameOfContentOffetchWeatherDataByCityIdMethod() {
        let cityId = "2172797"
        let expectedCityName = "Cairns"
        
        let expectationService = expectation(description: "\(#function)")
        
        var resultWeather : Weather?
        DataManager.fetchWeatherDataByCityId(city: cityId) {
            weather in
            
            resultWeather = weather
            
            expectationService.fulfill()
        }
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("Error: \(error.localizedDescription)")
            }
        }
        
        XCTAssert(resultWeather?.cityName == expectedCityName, "The city name is unexpected: \(String(describing: resultWeather?.cityName)), it should be \(expectedCityName)")
    }
    
    func testWeatherInfoOfContentOffetchWeatherDataByCityIdMethod() {
        let cityId = "2172797"
        
        let expectationService = expectation(description: "\(#function)")
        
        var resultWeather : Weather?
        DataManager.fetchWeatherDataByCityId(city: cityId) {
            weather in
            
            resultWeather = weather
            
            expectationService.fulfill()
        }
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("Error: \(error.localizedDescription)")
            }
        }
        
        //These value are used in the code, check they have values
        XCTAssert((resultWeather?.weatherInfo?.count)! > 0)
        XCTAssert((resultWeather?.weatherInfo?[0].main?.count)! > 0)
        XCTAssert((resultWeather?.weatherInfo?[0].description?.count)! > 0)
        XCTAssert((resultWeather?.weatherInfo?[0].icon?.count)! > 0)
    }
    
    func testMainOfContentOffetchWeatherDataByCityIdMethod() {
        let cityId = "2172797"
        
        let expectationService = expectation(description: "\(#function)")
        
        var resultWeather : Weather?
        DataManager.fetchWeatherDataByCityId(city: cityId) {
            weather in
            
            resultWeather = weather
            
            expectationService.fulfill()
        }
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("Error: \(error.localizedDescription)")
            }
        }
        
        //These value are used in the code, check they have values
        XCTAssert((resultWeather?.mainInfo?.temp != nil))
    }
    
    func testDownloadImageMethod() {
        let name = "10d"
        
        let expectationService = expectation(description: "\(#function)")
        
        var localImage : UIImage?
        DataManager.downloadImage(withName: name) {
            image in
            
            localImage = image
            
            expectationService.fulfill()
        }
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("Error: \(error.localizedDescription)")
            }
        }
        
        //These value are used in the code, check they have values
        XCTAssert((localImage != nil))
    }

    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}

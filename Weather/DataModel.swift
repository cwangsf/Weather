//
//  WeatherData.swift
//  Copyright © 2017 Cynthia Wang. All rights reserved.
//

import Foundation
import Gloss

struct City: Gloss.Decodable, Gloss.Encodable {
    func toJSON() -> JSON? {
        return jsonify([
            "id" ~~> self.id,
            "name" ~~> self.name,
            "country" ~~> self.country
            ])
    }
    
    let id: Int?
    let name: String?
    let country: String?
    
    
    init?(json: JSON) {
        id = "id" <~~ json
        name = "name" <~~ json
        country = "country" <~~ json
    }
}
struct Weather: Gloss.Decodable {
    let cityId: Int?
    let cityName: String?
    let weatherInfo: [WeatherInfo]?
    let mainInfo: MainInfo?
    
    init?(json: JSON) {
        cityId = "id" <~~ json
        cityName = "name" <~~ json
        weatherInfo = "weather" <~~ json
        mainInfo = "main" <~~ json
    }
}

/* sample:
 "weather": [{
 "id": 802,
 "main": "Clouds",
 "description": "scattered clouds",
 "icon": "03n"
	}]
 */
struct WeatherInfo: Gloss.Decodable {
    var weatherId: Int?
    var main: String?
    var description: String?
    var icon: String?
    
    init?(json: JSON) {
        weatherId = "id" <~~ json
        main = "main" <~~ json
        description = "description" <~~ json
        icon = "icon" <~~ json
    }
    
}
/* sample:
 "main": {
 "temp": 300.15,
 "pressure": 1007,
 "humidity": 74,
 "temp_min": 300.15,
 "temp_max": 300.15
	}
 */
struct MainInfo: Gloss.Decodable {
    var temp: Double?
    var pressure: Double?
    var humidity: Int?
    var temp_min: Double?
    var temp_max: Double?
    
    init?(json: JSON) {
        temp = "temp" <~~ json
        pressure = "pressure" <~~ json
        humidity = "humidity" <~~ json
        temp_min = "temp_min" <~~ json
        temp_max = "temp_max" <~~ json
    }
}

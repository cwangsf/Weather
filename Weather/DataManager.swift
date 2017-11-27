//
//  DataManager.swift
//  Weather
//
//  Created by Cynthia Wang on 11/19/17.
//  Copyright © 2017 Cynthia Wang. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import AlamofireImage
import Gloss

//in real projects, these will be defined in project/targets settings
let apiKey = "f495ea6e5a852daf7a96c8e638f8b61a"
let sampleCityUrl = "http://samples.openweathermap.org/data/2.5/weather?id=2172797&appid=b1b15e88fa797225412429c1c50c122a1"

struct DataManager {
    
    static func fetchWeatherDataByCityId(city id: String, completion: @escaping (Weather?) -> Void) {
        //let url = sampleCityUrl
        let url = "http://api.openweathermap.org/data/2.5/weather?id=\(id)&appid=\(apiKey)"
        print ("weather url: \(url)")
        let queue = DispatchQueue(label: "com.cwang.weather",
                                  qos: .userInitiated,
                                  attributes:.concurrent)
        
        Alamofire.request(
            url)
            .validate()
            .responseJSON(queue: queue, options: .allowFragments) { (response) -> Void in
                guard response.result.isSuccess else {
                    print("Error while fetching data: \(#function)")
                    completion(nil)
                    return
                }
                
                guard let value = response.result.value as? [String: AnyObject]
                    else {
                        print("Malformed data received from \(#function) service")
                        completion(nil)
                        return
                }
                
                let weather = Weather(json: value)
                completion(weather)
        }
    }

    
    static func cityList(completion: @escaping ([City]) -> Void ) {
        DispatchQueue.global(qos:.background).async {
            var cities = [City]()
            guard let path = Bundle.main.path(forResource: "uscitylist", ofType: "json") else { return }
            do {
                let jsonData = try Data(contentsOf: URL(fileURLWithPath: path))
                let cityDictList = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as! [[String: AnyObject]]
                
                for cityDict in cityDictList {
                    cities.append(City(json: cityDict)!)
                }
            } catch {
                
            }
            completion(cities)
        }
    }
    
    static func usCityList() {
        DispatchQueue.global(qos:.background).async {
            var cities = [City]()
            guard let path = Bundle.main.path(forResource: "citylist", ofType: "json") else { return }
            do {
                let jsonData = try Data(contentsOf: URL(fileURLWithPath: path))
                let cityDictList = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as! [[String: AnyObject]]
                
                for cityDict in cityDictList {
                    if cityDict["country"] as! String == "US" {
                        cities.append(City(json: cityDict)!)
                    }
                }
            } catch {
                
            }
            let usCityJSON = cities.toJSONArray()
            
            guard let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
            let fileUrl = documentDirectoryUrl.appendingPathComponent("uscitylist.json")

            // Transform array into data and save it into file
            do {
                let data = try JSONSerialization.data(withJSONObject: usCityJSON as Any, options: [])
                try data.write(to: fileUrl, options: [])
            } catch {
                print(error)
            }
        }
    }

    static func lastCityWeather() -> Weather? {
        guard let path = Bundle.main.path(forResource: "lastCityWeather", ofType: "json") else { return nil }
        
        do {
            let jsonData = try Data(contentsOf: URL(fileURLWithPath: path))
            let jsonDict = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as! [String: AnyObject]
            let weather = Weather(json: jsonDict)
            return weather
            
        } catch {
            return nil
        }
    }
    
    static func downloadImage(withName name: String, completion: @escaping (UIImage?) -> Void) {
        
        let queue = DispatchQueue(label: "com.cwang.weather",
                                  qos: .userInitiated,
                                  attributes:.concurrent)
        
        Alamofire.request("http://openweathermap.org/img/w/\(name).png").responseImage(queue: queue) { response in
            guard response.result.isSuccess else {
                print("Error while fetching data: \(#function)")
                completion(nil)
                return
            }
            
            if let image = response.result.value {
                completion(image)
            }
        }
    }

    
}

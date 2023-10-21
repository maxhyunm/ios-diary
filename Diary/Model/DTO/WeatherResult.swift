//
//  WeatherResult.swift
//  Diary
//
//  Created by Max, Hemg on 2023/09/13.
//

struct WeatherResult: Decodable {
    let weather: [Weather]
    
    struct Weather: Decodable {
        let id: Int
        let main: String
        let description: String
        let icon: String
    }
}

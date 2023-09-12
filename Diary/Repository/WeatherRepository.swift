//
//  WeatherRepository.swift
//  Diary
//
//  Created by 1 on 2023/09/11.
//

import CoreLocation

struct MainWeather: Decodable {
    let coord: Coord
    let weather: [Weather]
    let base: String
    let main: Main
    let visibility: Int
    let wind: Wind
    let clouds: Clouds
    let date: Int
    let sys: Sys
    let timezone, id: Int
    let name: String
    let cod: Int
  
    private enum CodingKeys: String, CodingKey {
        case coord, weather, base, main, visibility, wind, clouds
        case date = "dt"
        case sys, timezone, id, name, cod
    }
}

struct Coord: Decodable {
    let longitude: Double
    let latitude: Double
    
    private enum CodingKeys: String, CodingKey {
        case longitude = "lon"
        case latitude = "lat"
    }
}

struct Weather: Decodable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct Main: Decodable {
    let temp, feelsLike, tempMin, tempMax: Double
    let pressure, humidity, seaLevel, groundLevel: Int?
    
    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure, humidity
        case seaLevel = "sea_level"
        case groundLevel = "grnd_level"
    }
}

struct Sys: Decodable {
    let type, id: Int
    let country: String
    let sunrise, sunset: Int
}

struct Clouds: Decodable {
    let all: Int
}

struct Wind: Decodable {
    let speed: Double
    let deg: Int
    let gust: Double?
}

enum ApiError: Error {
    case unknown
    case invalidUrl
    case invalidResponse
    case failed
    case emptyData
    case requestFail
}

final class WeatherRepository {
    private let apiKey = "aaa5700cbd82d1a09e738731002f97be"
    private var dataTask: URLSessionDataTask?
    
    func fetchWeather(url: String, completionHandler: @escaping(Result<MainWeather, ApiError>) -> Void) {
        guard let url = URL(string: url) else {
            completionHandler(.failure(.invalidUrl))
            return
        }
        
        dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
            if error != nil {
                completionHandler(.failure(.requestFail))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299) ~= httpResponse.statusCode else {
                completionHandler(.failure(.emptyData))
                return
            }
            
            guard let data = data else {
                completionHandler(.failure(.emptyData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let data = try decoder.decode(MainWeather.self, from: data)
                completionHandler(.success(data))
            } catch {
                print("에러\(error)")
                completionHandler(.failure(.failed))
            }
        }
        self.dataTask?.resume()
    }
    
    func fetchLocation(location: CLLocation, _ completionHandler: @escaping(Result<MainWeather, ApiError>) -> Void) {
        let urlStr = "https://api.openweathermap.org/data/2.5/weather?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&appid=\(apiKey)"
     
        fetchWeather(url: urlStr, completionHandler: completionHandler)
    }
}

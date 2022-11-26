//
//  APIClient.swift
//  WeatherApp
//
//  Created by Carrington Tafadzwa Manyuchi on 2022/11/25.
//

import Foundation

class APIClient {
   
     static let shared: APIClient = APIClient()
     let apiKey = "8a43aa820f6bf583b388484487247784"
     let baseURL: String = "https://api.openweathermap.org/data/2.5/weather"
     
     func getWeatherDataURL(lat: String, lon: String) -> String{
          
          return "\(baseURL)?lat=\(lat)&lon=\(lon)&appid=\(apiKey)"
     }
   
   
}

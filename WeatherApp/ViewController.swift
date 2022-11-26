//
//  ViewController.swift
//  WeatherApp
//
//  Created by Carrington Tafadzwa Manyuchi on 2022/11/25.
//

import UIKit
import Alamofire
import CoreLocation

import SwiftyJSON


class ViewController: UIViewController {
    
    
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
     
     var locationManager = CLLocationManager()
     
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
     
     locationManager.delegate = self
     
     locationManager.desiredAccuracy = kCLLocationAccuracyBest
     
     locationManager.requestLocation()
     
     
    }
     /**
     func getWeatherWithAlamofire(lat: String, long: String) -> Void {
          
          guard let url = URL(string: APIClient.shared.getWeatherDataURL(lat: lat, lon: long)) else {
               
               print("could not form url")
               
               return
          }
          
          let headers: HTTPHeaders = [
               "Accept" : "application/json"
          ]
          
          let parameters: Parameters = [:]
          
          AF.request(url, method: HTTPMethod.get, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in
               
               
               if let jsonData = response.result.value as? [String:Any] {
                    
                    print(jsonData)
               }
      
          }
          

          
     }
     
     */
     
     
     func getWeatherWithAlamoFire(lat: String, lon: String) {
         guard let url = URL(string: APIClient.shared.getWeatherDataURL(lat: lat, lon: lon)) else {
         print("Could not find url")
      
         return
     }
      
     // Get JSON Method 1 (Change HTTP Request Method)
     let headers: HTTPHeaders = [
     "Accept": "application/json" // not necessary
     ]
     let parameters: Parameters = [:]
     AF.request(url, method: HTTPMethod.get, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseJSON { [weak self] (response) in
      
     guard let strongSelf = self else { return }
     switch response.result {
     case .success(let value):
     print(value) // Keep to confirm json is being returned
     DispatchQueue.main.async {
      //strongSelf.parseJSONManually(data: value as! [String: Any])
     strongSelf.parseJSONWithSwiftyJSON(data: value as! [String: Any])
     }
      
     case .failure(let error):
     print(error)
      
     }
     }
     }
     
     func parseJSONWithSwiftyJSON(data: [String: Any]) {
             let jsonData = JSON(data)
             if let humidity = jsonData["main"]["humidity"].int {
                 humidityLabel.text = "\(humidity)"
             }
             if let temperature = jsonData["main"]["temp"].double {
                 temperatureLabel.text = "\(Int(temperature))"
             }
             if let windSpeed = jsonData["wind"]["speed"].double {
                 windSpeedLabel.text = "\(windSpeed)"
             }
             if let name = jsonData["name"].string {
                 cityNameLabel.text = name
             }
         }
     
     
     func getWeatherWithURLSession(lat: String, long: String) -> Void {
          
          let apiKey = APIClient.shared.apiKey
          
          if var urlComponents = URLComponents(string: APIClient.shared.baseURL) {
               
               urlComponents.query = "lat=\(lat)&lon=\(long)&appid=\(apiKey)"
               guard let url = urlComponents.url else { return }
               
               var request = URLRequest(url: url)
               
               request.httpMethod = "GET"
               
               
               request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
               
               let config = URLSessionConfiguration.default
               
               let session = URLSession(configuration: config)
               
               let task = session.dataTask(with: request) { (data, responds, error) in
                    
                    if let error = error {
                         
                         print(error.localizedDescription)
                         return
                         
                    }
                    
                    // make our data non optional
                    guard let data = data else {return }
                    
                    //to retrieve JSON we use JSONSerialisation, throws potential errors we have to use do catch
                    
                    do {
                         
                         guard let weatherData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                              
                              print("there was ana error converting data into JSON")
                              
                              return
                              
                         }
                         
                         print(weatherData)
                         
                    } catch {
                         
                         print("error converting data inot JSON")
                         
                    }
      
               }
               task.resume()
          }
          
          /*
          
          guard let weatherURL = URL(string: APIClient.shared.getWeatherDataURL(lat: lat, lon: long)) else { return }
          
          URLSession.shared.dataTask(with: weatherURL) { (data, responds, error) in
               
               //handling potential error that will come out
               if let error = error {
                    
                    print(error.localizedDescription)
                    return
                    
               }
               
               // make our data non optional
               guard let data = data else {return }
               
               //to retrieve JSON we use JSONSerialisation, throws potential errors we have to use do catch
               
               do {
                    
                    guard let weatherData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                         
                         print("there was ana error converting data into JSON")
                         
                         return
                         
                    }
                    
                    print(weatherData)
                    
               } catch {
                    
                    print("error converting data inot JSON")
                    
               }
               
          }.resume()
 
 */
     }

   
}

extension ViewController: CLLocationManagerDelegate {
     
     
     func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
          
          print(error.localizedDescription)
     }
     
     
     func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
          
          if let location = locations.first {
               
               let latitude = String(location.coordinate.latitude)
               
               let longitude = String(location.coordinate.longitude)
               
               print(latitude)
               
               print(longitude)
               
               getWeatherWithAlamoFire(lat: latitude, lon: longitude)
               
               
          }
          
     }
     
     func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
          
          switch status {
          case .notDetermined:
               locationManager.requestWhenInUseAuthorization()
               
          case .authorizedAlways, .authorizedWhenInUse:
               locationManager.requestLocation()
          default:
               let alertController = UIAlertController(title: "Location Access Disabled", message: "Weather App needs your location to give a weather forecast. Open your settings to change authorization", preferredStyle: .alert)
               
               let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                    
                    alertController.dismiss(animated: true, completion: nil)
               }
               
               alertController.addAction(cancelAction)
               
               let openAction = UIAlertAction(title: "Open", style: .default) { (action) in
                    
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                         UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
               }
               
               alertController.addAction(openAction)
               
               present(alertController, animated: true, completion: nil)
               
               break
          }
     }
}


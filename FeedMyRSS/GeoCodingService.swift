import Foundation

//
//  GeoCodingService.swift
//  calimoto-app
//
//  Created by calimoto on 27.01.17.
//  Copyright © 2017 calimoto. All rights reserved.
//

typealias ServiceResponse = (JSON, NSError?) -> Void

public class GeoCodingService {
    
    let geocodingAPIServer = "http://62.138.3.10"
    
    static let shared = GeoCodingService()
    
    init() {
        
    }
    
    /*
     * create location search request for photon
     */
    
    private func createURLRequest(query: String) -> URL {
        var urlRequest = "\(geocodingAPIServer):30000/api?"
        urlRequest += "q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)"
        urlRequest += "&osm_tag=place"
        urlRequest += "&osm_tag=highway"
        urlRequest += "&osm_tag=railway:station"
        urlRequest += "&osm_tag=mountain_pass"
        urlRequest += "&osm_tag=amenity:fuel"
        urlRequest += "&osm_tag=tourism:viewpoint"
        urlRequest += "&osm_tag=shop:motorcycle"
        urlRequest += "&osm_tag=amenity:biergarten"
        urlRequest += "&osm_tag=amenity:cafe"
        urlRequest += "&osm_tag=building"
        urlRequest += "&limit=8"
        urlRequest += "&lang=\((Locale.current.languageCode)!)"
        
        if let location = locationHelper.lastKnownLocation {
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            urlRequest += "&lat=\(lat.description)&lon=\(lon.description)"
        }
        print(urlRequest)
        return URL(string: urlRequest)!
    }
 
    func newSearchQuery(searchString string: String, onCompletion: @escaping ServiceResponse) {
        let request = NSMutableURLRequest(url: createURLRequest(query: string))
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            if let jsonData = data {
                let json: JSON = JSON(data: jsonData)
                print(json)
                onCompletion(json, error as NSError?)
            } else {
                onCompletion(JSON.null, error as NSError?)
            }
        })
        task.resume()
    }
}

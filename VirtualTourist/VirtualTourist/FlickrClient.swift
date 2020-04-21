//
//  FlickrAPIClient.swift
//  VirtualTourist
//
//  Created by Gregory White on 3/10/16.
//  Copyright © 2016 Gregory White. All rights reserved.
//

import CoreLocation
import Foundation

struct FlickrClient {
    
    // MARK: - Constants
    
    struct API {
        static let PageKey       = "page"
        static let PerPageKey    = "perpage"
        static let PhotoKey      = "photo"
        static let PhotosKey     = "photos"
        static let StatusKey     = "stat"
        static let StatusValueOK = "ok"
        static let TitleKey      = "title"
        static let URLKey        = "url_m"
    }
    
    fileprivate struct HTTP {
        static let GETMethod       = "GET"
        static let RESTServicesURL = "https://api.flickr.com/services/rest/"
    }
    
    func url(lat: CLLocationDegrees, long: CLLocationDegrees, nextPage: Int64) -> String {
        return "https://api.flickr.com/services/rest/?api_key=850364777cd6c0359001c9aa67b5b1b4&content_type=1&extras=url_m&format=json&lat=\(lat)&lon=\(long)&method=flickr.photos.search&nojsoncallback=1&page=\(nextPage)&per_page=21&safe_search=1"
    }
    
}



// MARK: -
// MARK: - API

extension FlickrClient {
    
    func getListOfPhotos(at location: VTLocation, completionHandler: @escaping NetworkTaskCompletionHandler) {
        let urlString  = url(lat: location.lat, long: location.long, nextPage: location.nextPage)
        let components = URLComponents(string: urlString)
        var urlRequest = URLRequest(url: components!.url!)
        
        urlRequest.httpMethod = "GET"
        
        let networkTask = NetworkTask2(withURLRequest: urlRequest, completionHandler: completionHandler)
        networkTask.resume()
    }

//    func searchPhotos(at travelLocation: VirtualTouristTravelLocation, completionHandler: @escaping DataTaskWithRequestCompletionHandler) {
//        var components = URLComponents(string: HTTP.RESTServicesURL)
//        components!.query = travelLocation.searchQuery
//        
//        let URLRequest = NSMutableURLRequest(url: components!.url!)
//        URLRequest.httpMethod = HTTP.GETMethod
//        
//        let dataTaskWithRequest = DataTaskWithRequest(urlRequest: URLRequest, completionHandler: completionHandler)
//        dataTaskWithRequest.resume()
//    }
//    
//    func downloadPhoto(_ vtPhoto: VirtualTouristPhoto, completionHandler: @escaping DataTaskWithRequestCompletionHandler) -> URLSessionTask {
//        let components = URLComponents(string: vtPhoto.imageURLString)
//        let URLRequest = NSMutableURLRequest(url: components!.url!)
//        URLRequest.httpMethod = HTTP.GETMethod
//        
//        let dataTaskWithRequest = DataTaskWithRequest(urlRequest: URLRequest, completionHandler: completionHandler)
//        return dataTaskWithRequest.getImageDownloadTask()
//    }
    
}

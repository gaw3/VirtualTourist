//
//  FlickrAPIClient.swift
//  VirtualTourist
//
//  Created by Gregory White on 3/10/16.
//  Copyright © 2016 Gregory White. All rights reserved.
//

import CoreLocation
import Foundation

private let _shared = FlickrAPIClient()

final class FlickrAPIClient {
    
    class var shared: FlickrAPIClient {
        return _shared
    }
    
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
    
}



// MARK: -
// MARK: - API

extension FlickrAPIClient {

    func searchPhotos(at travelLocation: VirtualTouristTravelLocation, completionHandler: @escaping DataTaskWithRequestCompletionHandler) {
        var components = URLComponents(string: HTTP.RESTServicesURL)
        components!.query = travelLocation.searchQuery
        
        let URLRequest = NSMutableURLRequest(url: components!.url!)
        URLRequest.httpMethod = HTTP.GETMethod
        
        let dataTaskWithRequest = DataTaskWithRequest(urlRequest: URLRequest, completionHandler: completionHandler)
        dataTaskWithRequest.resume()
    }
    
    func downloadPhoto(_ vtPhoto: VirtualTouristPhoto, completionHandler: @escaping DataTaskWithRequestCompletionHandler) -> URLSessionTask {
        let components = URLComponents(string: vtPhoto.imageURLString)
        let URLRequest = NSMutableURLRequest(url: components!.url!)
        URLRequest.httpMethod = HTTP.GETMethod
        
        let dataTaskWithRequest = DataTaskWithRequest(urlRequest: URLRequest, completionHandler: completionHandler)
        return dataTaskWithRequest.getImageDownloadTask()
    }
    
}

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
    
    func url(lat: CLLocationDegrees, long: CLLocationDegrees, page: Int64) -> String {
        return "https://api.flickr.com/services/rest/?api_key=850364777cd6c0359001c9aa67b5b1b4&content_type=1&extras=url_m&format=json&lat=\(lat)&lon=\(long)&method=flickr.photos.search&nojsoncallback=1&page=\(page)&per_page=21&safe_search=1"
    }
    
}



// MARK: -
// MARK: - API

extension FlickrClient {
    
    func getImageDownloadTask(forPhoto vtPhoto: VTPhoto, completionHandler: @escaping NetworkTaskCompletionHandler) -> NetworkTask2 {
        let components = URLComponents(string: vtPhoto.url!)
        var urlRequest = URLRequest(url: components!.url!)
        
        urlRequest.httpMethod = String.HTTPMethod.get
        
        let networkTask = NetworkTask2(withURLRequest: urlRequest, completionHandler: completionHandler)
        return networkTask
    }
    
    func getListOfPhotos(at location: VTLocation, completionHandler: @escaping NetworkTaskCompletionHandler) {
        let urlString  = url(lat: location.lat, long: location.long, page: location.nextPage)
        let components = URLComponents(string: urlString)
        var urlRequest = URLRequest(url: components!.url!)
        
        urlRequest.httpMethod = String.HTTPMethod.get
        
        let networkTask = NetworkTask2(withURLRequest: urlRequest, completionHandler: completionHandler)
        networkTask.resume()
    }

}

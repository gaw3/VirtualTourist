//
//  FlickrAPIClient.swift
//  VirtualTourist
//
//  Created by Gregory White on 3/10/16.
//  Copyright © 2016 Gregory White. All rights reserved.
//

import CoreLocation
import Foundation

private let _sharedClient = FlickrAPIClient()

final internal class FlickrAPIClient: NSObject {

	class internal var sharedClient: FlickrAPIClient {
		return _sharedClient
	}

	// MARK: - API

	internal func searchPhotosByLocation(location: CLLocationCoordinate2D, completionHandler: APIDataTaskWithRequestCompletionHandler) {
		let components = NSURLComponents(string: "https://api.flickr.com/services/rest/")
		components!.query = FlickrSearchPhotosByLocationQuery(location: location).query

		let URLRequest = NSMutableURLRequest(URL: components!.URL!)
		URLRequest.HTTPMethod = "GET"

		let dataTaskWithRequest = APIDataTaskWithRequest(URLRequest: URLRequest, completionHandler: completionHandler)
		dataTaskWithRequest.resume()
	}

	internal func getRemotePhotoWithURLStringTask(URLString: String, completionHandler: APIDataTaskWithRequestCompletionHandler) -> NSURLSessionTask {
		let components = NSURLComponents(string: URLString)
		let URLRequest = NSMutableURLRequest(URL: components!.URL!)
		URLRequest.HTTPMethod = "GET"

		let dataTaskWithRequest = APIDataTaskWithRequest(URLRequest: URLRequest, completionHandler: completionHandler)
//		dataTaskWithRequest.resume()
		return dataTaskWithRequest.getImageDownloadTask()
	}

}
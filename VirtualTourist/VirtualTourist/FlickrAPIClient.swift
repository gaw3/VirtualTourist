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

	// MARK: - Internal Constants

	internal struct API {
		static let PageKey       = "page"
		static let PerPageKey    = "perpage"
		static let PhotoKey      = "photo"
		static let PhotosKey     = "photos"
		static let StatusKey     = "stat"
		static let StatusValueOK = "ok"
		static let TitleKey      = "title"
		static let URLKey        = "url_m"
	}

	// MARK: - Private Constants

	private struct HTTP {
		static let GETMethod       = "GET"
		static let RESTServicesURL = "https://api.flickr.com/services/rest/"
	}

	// MARK: - API

	internal func searchPhotosByLocation(travelLocation: VirtualTouristTravelLocation, completionHandler: APIDataTaskWithRequestCompletionHandler) {
		let components = NSURLComponents(string: HTTP.RESTServicesURL)
		components!.query = travelLocation.searchQuery

		let URLRequest = NSMutableURLRequest(URL: components!.URL!)
		URLRequest.HTTPMethod = HTTP.GETMethod

		let dataTaskWithRequest = APIDataTaskWithRequest(URLRequest: URLRequest, completionHandler: completionHandler)
		dataTaskWithRequest.resume()
	}

	internal func getRemotePhotoWithURLStringTask(URLString: String, completionHandler: APIDataTaskWithRequestCompletionHandler) -> NSURLSessionTask {
		let components = NSURLComponents(string: URLString)
		let URLRequest = NSMutableURLRequest(URL: components!.URL!)
		URLRequest.HTTPMethod = HTTP.GETMethod

		let dataTaskWithRequest = APIDataTaskWithRequest(URLRequest: URLRequest, completionHandler: completionHandler)
		return dataTaskWithRequest.getImageDownloadTask()
	}

}
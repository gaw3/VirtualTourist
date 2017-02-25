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

final class FlickrAPIClient: NSObject {

	class var sharedClient: FlickrAPIClient {
		return _sharedClient
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

	// MARK: - Private Constants

	fileprivate struct HTTP {
		static let GETMethod       = "GET"
		static let RESTServicesURL = "https://api.flickr.com/services/rest/"
	}

	// MARK: - API

	func searchPhotosByLocation(_ travelLocation: VirtualTouristTravelLocation, completionHandler: @escaping APIDataTaskWithRequestCompletionHandler) {
		var components = URLComponents(string: HTTP.RESTServicesURL)
		components!.query = travelLocation.searchQuery

		let URLRequest = NSMutableURLRequest(url: components!.url!)
		URLRequest.httpMethod = HTTP.GETMethod

		let dataTaskWithRequest = APIDataTaskWithRequest(urlRequest: URLRequest, completionHandler: completionHandler)
		dataTaskWithRequest.resume()
	}

	func getRemotePhoto(_ vtPhoto: VirtualTouristPhoto, completionHandler: @escaping APIDataTaskWithRequestCompletionHandler) -> URLSessionTask {
		let components = URLComponents(string: vtPhoto.imageURLString)
		let URLRequest = NSMutableURLRequest(url: components!.url!)
		URLRequest.httpMethod = HTTP.GETMethod

		let dataTaskWithRequest = APIDataTaskWithRequest(urlRequest: URLRequest, completionHandler: completionHandler)
		return dataTaskWithRequest.getImageDownloadTask()
	}

}

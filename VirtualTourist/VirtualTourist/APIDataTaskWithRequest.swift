//
//  APIDataTaskWithRequest.swift
//  VirtualTourist
//
//  Created by Gregory White on 3/12/16.
//  Copyright © 2016 Gregory White. All rights reserved.
//

import Foundation
import UIKit

typealias APIDataTaskWithRequestCompletionHandler = (result: AnyObject!, error: NSError?) -> Void
typealias JSONDictionary = [String: AnyObject]

final internal class APIDataTaskWithRequest: NSObject {

	// MARK: - Private Constants

	private struct LocalizedError {
		static let Domain         = "VirtualTouristExternalAPIInterfaceError"
		static let FlickrHostName = "www.flickr.com"
	}

	private struct LocalizedErrorCode {
		static let Network           = 1
		static let HTTP              = 2
		static let JSON              = 3
		static let JSONSerialization = 4
	}

	private struct LocalizedErrorDescription {
		static let Network           = "Network Error"
		static let HTTP              = "HTTP Error"
		static let JSON	           = "JSON Error"
		static let JSONSerialization = "JSON JSONSerialization Error"
	}

	// MARK: - Private Stored Variables

	private var URLRequest:        NSMutableURLRequest
	private var completionHandler: APIDataTaskWithRequestCompletionHandler

	// MARK: - API

	internal init(URLRequest: NSMutableURLRequest, completionHandler: APIDataTaskWithRequestCompletionHandler) {
		self.URLRequest        = URLRequest
		self.completionHandler = completionHandler

		super.init()
	}

	internal func getImageDownloadTask() -> NSURLSessionTask {

		let task = NSURLSession.sharedSession().dataTaskWithRequest(URLRequest) { (rawImageData, HTTPResponse, URLSessionError) in

			dispatch_async(dispatch_get_main_queue(), {
				NetworkActivityIndicatorManager.sharedManager.endActivity()
			})

			guard URLSessionError == nil else {
				let userInfo = [NSLocalizedDescriptionKey: LocalizedErrorDescription.Network, NSUnderlyingErrorKey: URLSessionError!]
				let error    = NSError(domain: LocalizedError.Domain, code: LocalizedErrorCode.Network, userInfo: userInfo)

				self.completeWithHandler(self.completionHandler, result: nil, error: error)
				return
			}

			let HTTPURLResponse = HTTPResponse as? NSHTTPURLResponse

			guard HTTPURLResponse?.statusCodeClass == .Successful else {
				let HTTPStatusText = NSHTTPURLResponse.localizedStringForStatusCode((HTTPURLResponse?.statusCode)!)
				let failureReason  = "HTTP status code = \(HTTPURLResponse?.statusCode), HTTP status text = \(HTTPStatusText)"
				let userInfo       = [NSLocalizedDescriptionKey: LocalizedErrorDescription.HTTP, NSLocalizedFailureReasonErrorKey: failureReason]
				let error          = NSError(domain: LocalizedError.Domain, code: LocalizedErrorCode.HTTP, userInfo: userInfo)

				self.completeWithHandler(self.completionHandler, result: nil, error: error)
				return
			}

			guard let rawImageData = rawImageData else {
				let userInfo = [NSLocalizedDescriptionKey: LocalizedErrorDescription.JSON]
				let error    = NSError(domain: LocalizedError.Domain, code: LocalizedErrorCode.JSON, userInfo: userInfo)

				self.completeWithHandler(self.completionHandler, result: nil, error: error)
				return
			}

			if let image = UIImage(data: rawImageData) {
				self.completeWithHandler(self.completionHandler, result: image, error: nil)
			} else {
				return
			}
			
		}

		NetworkActivityIndicatorManager.sharedManager.startActivity()
		task.resume()
		return task
	}

	internal func resume() {

		let task = NSURLSession.sharedSession().dataTaskWithRequest(URLRequest) { (rawJSONResponse, HTTPResponse, URLSessionError) in

			dispatch_async(dispatch_get_main_queue(), {
				NetworkActivityIndicatorManager.sharedManager.endActivity()
			})

			guard URLSessionError == nil else {
				let userInfo = [NSLocalizedDescriptionKey: LocalizedErrorDescription.Network, NSUnderlyingErrorKey: URLSessionError!]
				let error    = NSError(domain: LocalizedError.Domain, code: LocalizedErrorCode.Network, userInfo: userInfo)

				self.completeWithHandler(self.completionHandler, result: nil, error: error)
				return
			}

			let HTTPURLResponse = HTTPResponse as? NSHTTPURLResponse

			guard HTTPURLResponse?.statusCodeClass == .Successful else {
				let HTTPStatusText = NSHTTPURLResponse.localizedStringForStatusCode((HTTPURLResponse?.statusCode)!)
				let failureReason  = "HTTP status code = \(HTTPURLResponse?.statusCode), HTTP status text = \(HTTPStatusText)"
				let userInfo       = [NSLocalizedDescriptionKey: LocalizedErrorDescription.HTTP, NSLocalizedFailureReasonErrorKey: failureReason]
				let error          = NSError(domain: LocalizedError.Domain, code: LocalizedErrorCode.HTTP, userInfo: userInfo)

				self.completeWithHandler(self.completionHandler, result: nil, error: error)
				return
			}

			guard let rawJSONResponse = rawJSONResponse else {
				let userInfo = [NSLocalizedDescriptionKey: LocalizedErrorDescription.JSON]
				let error    = NSError(domain: LocalizedError.Domain, code: LocalizedErrorCode.JSON, userInfo: userInfo)

				self.completeWithHandler(self.completionHandler, result: nil, error: error)
				return
			}

			do {
				let JSONData = try NSJSONSerialization.JSONObjectWithData(rawJSONResponse, options: .AllowFragments) as! JSONDictionary

				self.completeWithHandler(self.completionHandler, result: JSONData, error: nil)
			} catch let JSONError as NSError {
				let userInfo = [NSLocalizedDescriptionKey: LocalizedErrorDescription.JSONSerialization, NSUnderlyingErrorKey: JSONError]
				let error    = NSError(domain: LocalizedError.Domain, code: LocalizedErrorCode.JSONSerialization, userInfo: userInfo)

				self.completeWithHandler(self.completionHandler, result: nil, error: error)
				return
			}

		}

		NetworkActivityIndicatorManager.sharedManager.startActivity()
		task.resume()
	}

	// MARK: - Private

	private func completeWithHandler(completionHandler: APIDataTaskWithRequestCompletionHandler, result: AnyObject!, error: NSError?) {

		dispatch_async(dispatch_get_main_queue()) {
			completionHandler(result: result, error: error)
		}
		
	}
	
}

//
//  DataTaskWithRequest.swift
//  VirtualTourist
//
//  Created by Gregory White on 3/12/16.
//  Copyright © 2016 Gregory White. All rights reserved.
//

import Foundation
import UIKit

typealias DataTaskWithRequestCompletionHandler = (_ result: AnyObject?, _ error: NSError?) -> Void
typealias JSONDictionary = [String: AnyObject]

final class DataTaskWithRequest {
    
    // MARK: - Constants
    
    fileprivate struct LocalizedError {
        static let Domain         = "VirtualTouristExternalAPIInterfaceError"
        static let FlickrHostName = "www.flickr.com"
    }
    
    fileprivate struct LocalizedErrorCode {
        static let Network           = 1
        static let HTTP              = 2
        static let JSON              = 3
        static let JSONSerialization = 4
        static let Image             = 5
    }
    
    fileprivate struct LocalizedErrorDescription {
        static let Network           = "Network Error"
        static let HTTP              = "HTTP Error"
        static let JSON	             = "JSON Error"
        static let JSONSerialization = "JSON Serialization Error"
        static let Image             = "Image Data Error"
    }
    
    // MARK: - Variables
    
    fileprivate var urlRequest:        NSMutableURLRequest
    fileprivate var completionHandler: DataTaskWithRequestCompletionHandler
    
    // MARK: - Init
    
    init(urlRequest: NSMutableURLRequest, completionHandler: @escaping DataTaskWithRequestCompletionHandler) {
        self.urlRequest        = urlRequest
        self.completionHandler = completionHandler
    }
    
}



// MARK: -
// MARK: - API

extension DataTaskWithRequest {

    func getImageDownloadTask() -> URLSessionTask {
        
        let task = URLSession.shared.dataTask(with: urlRequest as URLRequest, completionHandler: { (rawData, urlResponse, error) in
            
            NetworkActivityIndicatorManager.shared.end()
            
            guard !self.isError(urlSessionError: error as NSError?)                else { return }
            guard !self.isError(httpURLResponse: urlResponse as! HTTPURLResponse?) else { return }
            guard !self.isError(rawData: rawData, isImage: true)                   else { return }
            
            if let image = UIImage(data: rawData!) {
                self.completionHandler(image as AnyObject?, nil)
            } else {
                let userInfo = [NSLocalizedDescriptionKey: LocalizedErrorDescription.Image] as [String : Any]
                let error    = NSError(domain: LocalizedError.Domain, code: LocalizedErrorCode.Image, userInfo: userInfo)
                
                self.completionHandler(nil, error)
                return
            }
            
        })
        
        NetworkActivityIndicatorManager.shared.begin()
        task.resume()
        return task
    }
    
    func resume() {
        
        let task = URLSession.shared.dataTask(with: urlRequest as URLRequest, completionHandler: { (rawData, urlResponse, error) in
            
            NetworkActivityIndicatorManager.shared.end()
            
            guard !self.isError(urlSessionError: error as NSError?)                else { return }
            guard !self.isError(httpURLResponse: urlResponse as! HTTPURLResponse?) else { return }
            guard !self.isError(rawData: rawData, isImage: false)                  else { return }
            
            do {
                let JSONData = try JSONSerialization.jsonObject(with: rawData!, options: .allowFragments) as! JSONDictionary
                
                self.completionHandler(JSONData as AnyObject?, nil)
            } catch let JSONError as NSError {
                let userInfo = [NSLocalizedDescriptionKey: LocalizedErrorDescription.JSONSerialization, NSUnderlyingErrorKey: JSONError] as [String : Any]
                let error    = NSError(domain: LocalizedError.Domain, code: LocalizedErrorCode.JSONSerialization, userInfo: userInfo)
                
                self.completionHandler(nil, error)
                return
            }
            
        })
        
        NetworkActivityIndicatorManager.shared.begin()
        task.resume()
    }
    
}



// MARK: -
// MARK: - Private Helpers

private extension DataTaskWithRequest {
    
    func isError(rawData data: Data?, isImage: Bool) -> Bool {
        
        guard data != nil else {
            let userInfo = [NSLocalizedDescriptionKey: (isImage ? LocalizedErrorDescription.Image : LocalizedErrorDescription.JSON)]
            let error    = NSError(domain: LocalizedError.Domain, code: (isImage ? LocalizedErrorCode.Image : LocalizedErrorCode.JSON), userInfo: userInfo)
            
            self.completionHandler(nil, error)
            return true
        }
        
        return false
    }
    
    func isError(httpURLResponse response: HTTPURLResponse?) -> Bool {
        
        guard response != nil else { return true }
        
        guard response!.statusCodeClass == .successful else {
            let httpStatusText = Foundation.HTTPURLResponse.localizedString(forStatusCode: response!.statusCode)
            let failureReason  = "HTTP status code = \(response!.statusCode), HTTP status text = \(httpStatusText)"
            let userInfo       = [NSLocalizedDescriptionKey: LocalizedErrorDescription.HTTP, NSLocalizedFailureReasonErrorKey: failureReason]
            let error          = NSError(domain: LocalizedError.Domain, code: LocalizedErrorCode.HTTP, userInfo: userInfo)
            
            self.completionHandler(nil, error)
            return true
        }
        
        return false
    }
    
    func isError(urlSessionError error: NSError?) -> Bool {
        
        guard error == nil else {
            let userInfo = [NSLocalizedDescriptionKey: LocalizedErrorDescription.Network, NSUnderlyingErrorKey: error!] as [String : Any]
            let newError = NSError(domain: LocalizedError.Domain, code: LocalizedErrorCode.Network, userInfo: userInfo)
            
            self.completionHandler(nil, newError)
            return true
        }
        
        return false
    }

}



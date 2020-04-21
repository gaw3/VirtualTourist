//
//  NetworkTask2.swift
//  VirtualTourist
//
//  Created by Gregory White on 4/20/20.
//  Copyright © 2020 Gregory White. All rights reserved.
//

import Foundation

typealias NetworkTaskCompletionHandler = (_ result: Data?, _ error: NSError?) -> Void
typealias UserInfoDictionary           = [String: Any]

struct NetworkTask2 {
    
    // MARK: - Variables
    
    private var completionHandler: NetworkTaskCompletionHandler
    private var isImageData:       Bool
    private var task:              URLSessionTask? = nil
    private var urlRequest:        URLRequest
    
    // MARK: - Initializers
    
    init(withURLRequest: URLRequest, isDownloadingImage: Bool = false, completionHandler: @escaping NetworkTaskCompletionHandler) {
        self.urlRequest        = withURLRequest
        self.completionHandler = completionHandler
        self.isImageData       = isDownloadingImage
        self.task              = buildTask()
    }
    
}



// MARK: -
// MARK: - API

extension NetworkTask2 {
    
    func cancel() {
        task!.cancel()
    }
    
    func getState() -> URLSessionTask.State { return task!.state }
    
    func resume() {
        task!.resume()
    }
    
}



// MARK: -
// MARK: - Private Helpers

private extension NetworkTask2 {
    
    func buildTask() -> URLSessionTask {

        let task = URLSession.shared.dataTask(with: urlRequest, completionHandler: { (rawData, urlResponse, urlSessionError) in

            if let error = self.localError(fromURLSessionError: urlSessionError) {
                self.completionHandler(rawData, error)
                return
            }
            
            if let error = self.localError(fromURLResponse: urlResponse) {
                self.completionHandler(rawData, error)
                return
            }
            
            self.completionHandler(rawData, nil)
        })

        return task
    }
    
    func localError(fromURLResponse response: URLResponse?) -> NSError? {
        
        guard response != nil else {
            let localErrorCode = LocalErrorCode.noURLResponse
            
            return NSError(domain: LocalErrorCode.domain.description,
                             code: localErrorCode.rawValue,
                         userInfo: [NSLocalizedDescriptionKey: localErrorCode.description,
                                    NSURLErrorKey:             urlRequest.url!] as UserInfoDictionary)
        }
        
        let httpResponse   = response as! HTTPURLResponse
        let httpStatusCode = httpResponse.statusCode
        let httpStatusText = Foundation.HTTPURLResponse.localizedString(forStatusCode: httpStatusCode)
        let httpStatus     = "HTTP return code = (\(httpStatusCode) : \(httpStatusText))"
        
        guard httpResponse.statusCodeClass == .successful else {
            let localErrorCode = (httpStatusCode == 404 ? LocalErrorCode.notFound
                                                        : LocalErrorCode.badHTTPResponse)
            
            return NSError(domain: LocalErrorCode.domain.description,
                             code: localErrorCode.rawValue,
                         userInfo: [NSLocalizedDescriptionKey:        localErrorCode.description,
                                    NSLocalizedFailureReasonErrorKey: httpStatus,
                                    NSURLErrorKey:                    httpResponse.url!] as UserInfoDictionary)
        }
        
        return nil
    }

    func localError(fromURLSessionError error: Error?) -> NSError? {
        
        guard error == nil else {
            let nsError        = error! as NSError
            let localErrorCode = (nsError.code == NSURLErrorCancelled ? LocalErrorCode.taskCancelled
                                                                      : LocalErrorCode.badURLSession)
            
            return NSError(domain: LocalErrorCode.domain.description,
                             code: localErrorCode.rawValue,
                         userInfo: [NSLocalizedDescriptionKey: localErrorCode.description,
                                    NSURLErrorKey:             urlRequest.url!,
                                    NSUnderlyingErrorKey:      error!] as UserInfoDictionary)
        }
        
        return nil
    }

}

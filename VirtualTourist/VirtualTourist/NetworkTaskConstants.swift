//
//  NetworkTaskConstants.swift
//  VirtualTourist
//
//  Created by Gregory White on 4/20/20.
//  Copyright © 2020 Gregory White. All rights reserved.
//

import Foundation

enum LocalErrorCode: Int {
    case domain          = 0
    case taskCancelled   = 1
    case badURLSession   = 2
    case noURLResponse   = 3
    case badHTTPResponse = 4
    case noRawData       = 5
    case badImageFormat  = 6
    case badJSONFormat   = 7
    case notFound        = 8
    
    var description: String {
        
        switch self {
        case .domain:          return "VirtualTouristExternalAPIError"
        case .taskCancelled:   return "Network Task Cancelled"
        case .badURLSession:   return "Network Error"
        case .noURLResponse:   return "No URL Response From External Server"
        case .badHTTPResponse: return "Bad HTTP Reponse From External Server"
        case .noRawData:       return "Data Receipt Error"
        case .badImageFormat:  return "Image Format Error"
        case .badJSONFormat:   return "JSON Format Error"
        case .notFound:        return "Not Found"
        }
        
    }
    
}

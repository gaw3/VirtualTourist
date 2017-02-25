//
//  NSHTTPURLResponseExtensions.swift
//  VirtualTourist
//
//  Created by Gregory White on 3/12/16.
//  Copyright © 2016 Gregory White. All rights reserved.
//

import Foundation

extension HTTPURLResponse {
    
    enum HTTPStatusCodeClass: Int {
        case informational = 1,
        successful,
        redirection,
        clientError,
        serverError
    }
    
    // MARK: - Variables
    
    var statusCodeClass: HTTPStatusCodeClass {
        
        if let scClass = HTTPStatusCodeClass.init(rawValue: self.statusCode / 100) {
            return scClass
        } else {
            return .serverError
        }
        
    }
    
}

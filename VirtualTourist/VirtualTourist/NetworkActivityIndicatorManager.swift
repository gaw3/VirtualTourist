//
//  NetworkActivityIndicatorManager.swift
//  VirtualTourist
//
//  Created by Gregory White on 2/27/16.
//  Copyright © 2016 Gregory White. All rights reserved.
//

import Foundation
import UIKit

private let _shared = NetworkActivityIndicatorManager()

final class NetworkActivityIndicatorManager {
    
    class var shared: NetworkActivityIndicatorManager {
        return _shared
    }
    
    // MARK: - Constants
    
    fileprivate struct QName {
        static let NAIUpdateQueue = "com.gaw3.OnTheMap.NetworkActivityIndicatorUpdateQueue"
    }
    
    // MARK: - Variables
    
    fileprivate var numOfUpdateTasks      = 0
    fileprivate let concurrentUpdateQueue = DispatchQueue(label: QName.NAIUpdateQueue, attributes: DispatchQueue.Attributes.concurrent)
}



// MARK: -
// MARK: - API

extension NetworkActivityIndicatorManager {
    
    func begin() {
        
//        concurrentUpdateQueue.sync(execute: {
//            
//            if !UIApplication.shared.isStatusBarHidden {
//                
//                if !UIApplication.shared.isNetworkActivityIndicatorVisible {
//                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
//                    self.numOfUpdateTasks = 0
//                }
//                
//                self.numOfUpdateTasks += 1
//            }
//            
//        })
        
    }
    
    func end() {
        
//        concurrentUpdateQueue.sync(execute: {
//            
//            if !UIApplication.shared.isStatusBarHidden {
//                self.numOfUpdateTasks -= 1
//                
//                if self.numOfUpdateTasks <= 0 {
//                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
//                    self.numOfUpdateTasks = 0
//                }
//                
//            }
//            
//        })
        
    }
    
}

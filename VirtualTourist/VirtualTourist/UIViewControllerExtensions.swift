//
//  UIViewControllerExtensions.swift
//  VirtualTourist
//
//  Created by Gregory White on 2/27/16.
//  Copyright © 2016 Gregory White. All rights reserved.
//

import CoreData
import UIKit

extension UIViewController {
    
    // MARK: - API
    
    func presentAlert(_ title: String, message: String) {
        let alert  = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: Alert.ActionTitle.OK, style: .default, handler: nil)
        alert.addAction(action)
        
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true, completion: nil)
        })
        
    }
    
}

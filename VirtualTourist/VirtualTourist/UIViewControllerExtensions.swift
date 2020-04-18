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
    
    func presentAlert(_ title: String.AlertTitle, message: String.AlertMessage) {
        let alert  = UIAlertController(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
        let action = UIAlertAction(title: String.ActionTitle.ok, style: .default, handler: nil)
        alert.addAction(action)
        
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true, completion: nil)
        })
        
    }

}

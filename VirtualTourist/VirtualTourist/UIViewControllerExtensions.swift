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

	// MARK: - Private Constants

	fileprivate struct Alert {
		static let ActionTitle = "OK"
	}

	// MARK: - Variables

    var flickrClient: FlickrAPIClient {
		return FlickrAPIClient.sharedClient
	}

    var nai: NetworkActivityIndicatorManager {
		return NetworkActivityIndicatorManager.sharedManager
	}

	// MARK: - API

    func presentAlert(_ title: String, message: String) {
		let alert  = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let action = UIAlertAction(title: Alert.ActionTitle, style: .default, handler: nil)
		alert.addAction(action)

		DispatchQueue.main.async(execute: {
			self.present(alert, animated: true, completion: nil)
		})

	}

}

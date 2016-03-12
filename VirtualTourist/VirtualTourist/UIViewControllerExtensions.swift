//
//  UIViewControllerExtensions.swift
//  VirtualTourist
//
//  Created by Gregory White on 2/27/16.
//  Copyright © 2016 Gregory White. All rights reserved.
//

import UIKit

extension UIViewController {

	// MARK: - Private Constants

	private struct Alert {
		static let ActionTitle = "OK"
	}

	// MARK: - Internal Computed Variables

	internal var nai: NetworkActivityIndicatorManager {
		return NetworkActivityIndicatorManager.sharedManager
	}

	// MARK: - API

	internal func presentAlert(title: String, message: String) {
		let alert  = UIAlertController(title: title, message: message, preferredStyle: .Alert)
		let action = UIAlertAction(title: Alert.ActionTitle, style: .Default, handler: nil)
		alert.addAction(action)

		dispatch_async(dispatch_get_main_queue(), {
			self.presentViewController(alert, animated: true, completion: nil)
		})

	}

}
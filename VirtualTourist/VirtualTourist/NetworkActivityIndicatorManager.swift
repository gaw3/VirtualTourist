//
//  NetworkActivityIndicatorManager.swift
//  VirtualTourist
//
//  Created by Gregory White on 2/27/16.
//  Copyright © 2016 Gregory White. All rights reserved.
//

import Foundation
import UIKit

private let _sharedClient = NetworkActivityIndicatorManager()

final class NetworkActivityIndicatorManager: NSObject {

	class var sharedManager: NetworkActivityIndicatorManager {
		return _sharedClient
	}

	// MARK: - Private Constants

	fileprivate struct QName {
		static let NAIUpdateQueue = "com.gaw3.OnTheMap.NetworkActivityIndicatorUpdateQueue"
	}

	// MARK: - Private Stored Variables

	fileprivate var numOfUpdateTasks      = 0
	fileprivate let concurrentUpdateQueue = DispatchQueue(label: QName.NAIUpdateQueue, attributes: DispatchQueue.Attributes.concurrent)

	// MARK: - Private Computed Variables

	fileprivate var app: UIApplication {
		return UIApplication.shared
	}

	// MARK: - API

	func completeAllActivities() {

		concurrentUpdateQueue.sync(execute: {

			if !self.app.isStatusBarHidden {
				self.app.isNetworkActivityIndicatorVisible = false
				self.numOfUpdateTasks = 0
			}

		})

	}

	func endActivity() {

		concurrentUpdateQueue.sync(execute: {

			if !self.app.isStatusBarHidden {
				self.numOfUpdateTasks -= 1

				if self.numOfUpdateTasks <= 0 {
					self.app.isNetworkActivityIndicatorVisible = false
					self.numOfUpdateTasks = 0
				}

			}

		})

	}

	func startActivity() {

		concurrentUpdateQueue.sync(execute: {

			if !self.app.isStatusBarHidden {

				if !self.app.isNetworkActivityIndicatorVisible {
					self.app.isNetworkActivityIndicatorVisible = true
					self.numOfUpdateTasks = 0
				}

				self.numOfUpdateTasks += 1
			}

		})

	}

	// MARK: - Private
	
	override fileprivate init() {
		super.init()
	}
	
}

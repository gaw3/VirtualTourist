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

final internal class NetworkActivityIndicatorManager: NSObject {

	class internal var sharedManager: NetworkActivityIndicatorManager {
		return _sharedClient
	}

	// MARK: - Private Constants

	private struct QName {
		static let NAIUpdateQueue = "com.gaw3.OnTheMap.NetworkActivityIndicatorUpdateQueue"
	}

	// MARK: - Private Stored Variables

	private var numOfUpdateTasks      = 0
	private let concurrentUpdateQueue = dispatch_queue_create(QName.NAIUpdateQueue, DISPATCH_QUEUE_CONCURRENT)

	// MARK: - Private Computed Variables

	private var app: UIApplication {
		return UIApplication.sharedApplication()
	}

	// MARK: - API

	internal func completeAllActivities() {

		dispatch_sync(concurrentUpdateQueue, {

			if !self.app.statusBarHidden {
				self.app.networkActivityIndicatorVisible = false
				self.numOfUpdateTasks = 0
			}

		})

	}

	internal func endActivity() {

		dispatch_sync(concurrentUpdateQueue, {

			if !self.app.statusBarHidden {
				self.numOfUpdateTasks--

				if self.numOfUpdateTasks <= 0 {
					self.app.networkActivityIndicatorVisible = false
					self.numOfUpdateTasks = 0
				}

			}

		})

	}

	internal func startActivity() {

		dispatch_sync(concurrentUpdateQueue, {

			if !self.app.statusBarHidden {

				if !self.app.networkActivityIndicatorVisible {
					self.app.networkActivityIndicatorVisible = true
					self.numOfUpdateTasks = 0
				}

				self.numOfUpdateTasks++
			}

		})

	}

	// MARK: - Private
	
	override private init() {
		super.init()
	}
	
}

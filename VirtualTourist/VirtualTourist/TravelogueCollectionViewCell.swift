//
//  TravelogueCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Gregory White on 3/24/16.
//  Copyright © 2016 Gregory White. All rights reserved.
//

import UIKit

class TravelogueCollectionViewCell: UICollectionViewCell {

	// MARK: - Internal Constants

	internal struct UI {
		static let ReuseID = "TravelogueCollectionViewCell"
	}

	internal var title:     String?
	internal var URLString: String?

	// MARK: - Internal Computed Variables

	var taskToCancelIfCellIsReused: NSURLSessionTask? {

		didSet {
			if let taskToCancel = oldValue {
				taskToCancel.cancel()
			}

		}

	}

	// MARK: - IB Outlets

	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
}
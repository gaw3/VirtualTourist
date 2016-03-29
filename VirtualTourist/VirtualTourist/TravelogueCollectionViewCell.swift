//
//  TravelogueCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Gregory White on 3/24/16.
//  Copyright © 2016 Gregory White. All rights reserved.
//

import UIKit

final internal class TravelogueCollectionViewCell: UICollectionViewCell {

	// MARK: - Internal Constants

	internal struct UI {
		static let ReuseID = "TravelogueCollectionViewCell"
	}

	// MARK: - Internal Stored Variables

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
	@IBOutlet weak var imageView:			  UIImageView!
}
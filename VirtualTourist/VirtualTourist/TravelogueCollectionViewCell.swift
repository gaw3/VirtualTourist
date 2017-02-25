//
//  TravelogueCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Gregory White on 3/24/16.
//  Copyright © 2016 Gregory White. All rights reserved.
//

import UIKit

final class TravelogueCollectionViewCell: UICollectionViewCell {

	// MARK: - Constants

	struct UI {
		static let ReuseID = "TravelogueCollectionViewCell"
	}

	// MARK: - Variables

	var title:     String?
	var URLString: String?

	// MARK: - Variables

	var taskToCancelIfCellIsReused: URLSessionTask? {

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

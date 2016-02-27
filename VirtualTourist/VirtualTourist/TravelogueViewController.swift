//
//  TravelogueViewController.swift
//  VirtualTourist
//
//  Created by Gregory White on 2/26/16.
//  Copyright © 2016 Gregory White. All rights reserved.
//

import UIKit

internal class TravelogueViewController: UIViewController {

	// MARK: - Internal Constants

	internal struct UI {
		static let StoryboardID = "TravelogueVC"
	}

	// MARK: - View Events

	override internal func viewDidLoad() {
		super.viewDidLoad()
		// point the map view to the right place
		// fill up the collection view
		//   > first check persistent data
		//   > if collection empty, download one
	}

}

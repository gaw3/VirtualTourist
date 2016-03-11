//
//  TravelogueViewController.swift
//  VirtualTourist
//
//  Created by Gregory White on 2/26/16.
//  Copyright © 2016 Gregory White. All rights reserved.
//

import MapKit
import UIKit

final internal class TravelogueViewController: UIViewController {

	// MARK: - Internal Constants

	internal struct UI {
		static let StoryboardID = "TravelogueVC"
	}

	// MARK: - Internal Stored Variables

	internal var tlPinAnnoView: TravelLocationPinAnnotationView? = nil

	// MARK: - IB Outlets

	@IBOutlet weak var mapView: MKMapView!

	// MARK: - View Events

	override internal func viewDidLoad() {
		super.viewDidLoad()
		// point the map view to the right place
		// fill up the collection view
		//   > first check persistent data
		//   > if collection empty, download one
	}

}



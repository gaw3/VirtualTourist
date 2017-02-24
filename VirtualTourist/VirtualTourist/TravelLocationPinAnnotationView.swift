//
//  TravelLocationPinAnnotationView.swift
//  VirtualTourist
//
//  Created by Gregory White on 2/26/16.
//  Copyright © 2016 Gregory White. All rights reserved.
//

import CoreGraphics
import Foundation
import MapKit
import UIKit

final internal class TravelLocationPinAnnotationView: MKPinAnnotationView {

	// MARK: - Internal Constants

	internal struct UI {
		static let ReuseID = "TravelLocsPinAnnoViewReuseID"
	}

	// MARK: - API

	init(annotation: MKPointAnnotation) {
		super.init(annotation: annotation, reuseIdentifier: UI.ReuseID)

		animatesDrop   = true
		canShowCallout = false
        pinTintColor   = MKPinAnnotationView.redPinColor()
		rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

}

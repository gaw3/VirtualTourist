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

internal class TravelLocationPinAnnotationView: MKPinAnnotationView {

	// MARK: - Internal Constants

	internal struct UI {
		static let ReuseID = "TravelLocsPinAnnoViewReuseID"
	}

	// MARK: - API

	init(annotation: MKAnnotation?) {
		super.init(annotation: annotation, reuseIdentifier: UI.ReuseID)
		
		animatesDrop   = true
		canShowCallout = false
      pinTintColor   = MKPinAnnotationView.redPinColor()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
	}

}
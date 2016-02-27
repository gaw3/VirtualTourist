//
//  TravelLocationsMapViewController.swift
//  VirtualTourist
//
//  Created by Gregory White on 2/24/16.
//  Copyright © 2016 Gregory White. All rights reserved.
//

import MapKit
import UIKit

final internal class TravelLocationsMapViewController: UIViewController {

	// MARK: - IB Outlets
	
	@IBOutlet      internal var longPress: UILongPressGestureRecognizer!
	@IBOutlet weak internal var mapView: MKMapView!

	// MARK: - View Events

	override internal func viewDidLoad() {
		super.viewDidLoad()

		mapView.addGestureRecognizer(longPress)
	}

	// MARK: - IB Actions

	@IBAction internal func handleLongPress(gesture: UIGestureRecognizer) {

		if gesture.state == .Began {
			let annotation = MKPointAnnotation()
			annotation.coordinate = mapView.convertPoint(gesture.locationInView(mapView), toCoordinateFromView: mapView)

			mapView.addAnnotation(annotation)
		}

	}

	// MARK: - MKMapViewDelegate

	internal func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
 		mapView.deselectAnnotation(view.annotation!, animated: true)

		let travelogueVC = self.storyboard?.instantiateViewControllerWithIdentifier(TravelogueViewController.UI.StoryboardID)
								 as! TravelogueViewController

		navigationController?.pushViewController(travelogueVC, animated: true)
	}

	internal func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
		var tlPinAnnoView = mapView.dequeueReusableAnnotationViewWithIdentifier(TravelLocationPinAnnotationView.UI.ReuseID)
								  as? TravelLocationPinAnnotationView

		if let _ = tlPinAnnoView {
			tlPinAnnoView!.annotation = annotation
		} else {
			tlPinAnnoView = TravelLocationPinAnnotationView(annotation: annotation)
		}

		return tlPinAnnoView
	}

}

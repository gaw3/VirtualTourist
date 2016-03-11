//
//  TravelLocationsMapViewController.swift
//  VirtualTourist
//
//  Created by Gregory White on 2/24/16.
//  Copyright © 2016 Gregory White. All rights reserved.
//

import CoreLocation
import MapKit
import UIKit

final internal class TravelLocationsMapViewController: UIViewController {

	// MARK: - Private Constants

	private struct Alert {

		struct Message {
			static let NoPlacemarks = "Did not receive any placemarks"
		}

		struct Title {
			static let BadGeocode = "Unable to geocode location"
		}

	}

	// MARK: - Private Stored Variables

	private var pleaseWaitView:    PleaseWaitView? = nil
	private var currentAnnotation: TravelLocationAnnotation? = nil
	
	// MARK: - IB Outlets
	
	@IBOutlet      internal var longPress: UILongPressGestureRecognizer!
	@IBOutlet weak internal var mapView: MKMapView!

	// MARK: - View Events

	override internal func viewDidLoad() {
		super.viewDidLoad()

		initPleaseWaitView()
		mapView.addGestureRecognizer(longPress)
	}

	// MARK: - IB Actions

	@IBAction internal func handleLongPress(gesture: UIGestureRecognizer) {

		if gesture.state == .Began {
			currentAnnotation = TravelLocationAnnotation()
			currentAnnotation!.coordinate = mapView.convertPoint(gesture.locationInView(mapView), toCoordinateFromView: mapView)

			pleaseWaitView!.startActivityIndicator()

			let location = CLLocation(latitude: currentAnnotation!.coordinate.latitude, longitude: currentAnnotation!.coordinate.longitude)
			let geocoder = CLGeocoder()

			nai.startActivity()
			geocoder.reverseGeocodeLocation(location, completionHandler: geocodeCompletionHandler)
		}

	}

	// MARK: - MKMapViewDelegate

	internal func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {

		if control == view.rightCalloutAccessoryView {
			let travelogueVC = self.storyboard?.instantiateViewControllerWithIdentifier(TravelogueViewController.UI.StoryboardID)
									 as! TravelogueViewController

			travelogueVC.tlPinAnnoView = view as? TravelLocationPinAnnotationView
			navigationController?.pushViewController(travelogueVC, animated: true)
		}

	}

	internal func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
		var tlPinAnnoView = mapView.dequeueReusableAnnotationViewWithIdentifier(TravelLocationPinAnnotationView.UI.ReuseID)
								  as? TravelLocationPinAnnotationView

		if let _ = tlPinAnnoView {
			tlPinAnnoView!.annotation = annotation as! TravelLocationAnnotation
		} else {
			tlPinAnnoView = TravelLocationPinAnnotationView(annotation: annotation as? TravelLocationAnnotation)
		}

		return tlPinAnnoView
	}

	// MARK: - Private:  Completion Handlers as Computed Variables

	private var geocodeCompletionHandler: CLGeocodeCompletionHandler {

		return { (placemarks, error) -> Void in

         self.nai.endActivity()

			guard error == nil else {
				self.presentAlert(Alert.Title.BadGeocode, message: error!.localizedDescription)
				return
			}

			guard placemarks != nil else {
				self.presentAlert(Alert.Title.BadGeocode, message: Alert.Message.NoPlacemarks)
				return
			}

			guard placemarks!.count > 0 else {
				self.presentAlert(Alert.Title.BadGeocode, message: Alert.Message.NoPlacemarks)
				return
			}

			self.currentAnnotation!.placemark = placemarks![0] as CLPlacemark

			dispatch_async(dispatch_get_main_queue(), {
				self.mapView.addAnnotation(self.currentAnnotation!)
			})

		}

	}

	// MARK: - Private UI Helpers

	private func initPleaseWaitView() {
		pleaseWaitView = PleaseWaitView(requestingView: view)
		view.addSubview(pleaseWaitView!.dimmedView)
		view.bringSubviewToFront(pleaseWaitView!.dimmedView)
	}

}

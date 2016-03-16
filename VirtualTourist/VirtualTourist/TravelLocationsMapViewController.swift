//
//  TravelLocationsMapViewController.swift
//  VirtualTourist
//
//  Created by Gregory White on 2/24/16.
//  Copyright © 2016 Gregory White. All rights reserved.
//

import CoreData
import CoreLocation
import MapKit
import UIKit

final internal class TravelLocationsMapViewController: UIViewController, NSFetchedResultsControllerDelegate {

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
	private var currentAnnotation: MKPointAnnotation? = nil
//	private var currentTravelLocation: VirtualTouristTravelLocation? = nil

	lazy private var frc: NSFetchedResultsController = {
		let fetchRequest = NSFetchRequest(entityName: VirtualTouristTravelLocation.Consts.EntityName)
		fetchRequest.sortDescriptors = []

		let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataManager.sharedManager.moc, sectionNameKeyPath: nil, cacheName: nil)
		frc.delegate = self
		
		return frc
	}()

	// MARK: - IB Outlets

	@IBOutlet      internal var longPress: UILongPressGestureRecognizer!
	@IBOutlet weak internal var mapView:   MKMapView!

	// MARK: - View Events

	override internal func viewDidLoad() {
		super.viewDidLoad()

//		initPleaseWaitView()
		mapView.addGestureRecognizer(longPress)

		do {
			try frc.performFetch()

			for travelLocation in frc.fetchedObjects as! [VirtualTouristTravelLocation] {
				let annotation = MKPointAnnotation()
				annotation.coordinate.latitude  = travelLocation.latitude  as CLLocationDegrees
				annotation.coordinate.longitude = travelLocation.longitude as CLLocationDegrees
				mapView.addAnnotation(annotation)
			}

		} catch let error as NSError {
			print("\(error)")
		}

	}

	// MARK: - IB Actions

	@IBAction internal func handleLongPress(gesture: UIGestureRecognizer) {

		if gesture.state == .Began {
			print("gesture began")
			let coord = mapView.convertPoint(gesture.locationInView(mapView), toCoordinateFromView: mapView)
			_ = VirtualTouristTravelLocation(coordinate: coord, context: CoreDataManager.sharedManager.moc)
			CoreDataManager.sharedManager.saveContext()
		}

	}

	// MARK: - NSFetchedResultsControllerDelegate

	func controllerDidChangeContent(controller: NSFetchedResultsController) {
		print("controller DidChangeContent called")
	}

	func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {

		print("controller didChangeObject called")

		if type == .Insert {
			let travelLocation = anObject as! VirtualTouristTravelLocation
			mapView.addAnnotation(travelLocation.pointAnnotation)
		} else if type == .Delete {
			// delete pin from view
		}
							
	}

	func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
						 atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
		print("controller didChangeSection called")
	}

	func controllerWillChangeContent(controller: NSFetchedResultsController) {
		print("controller WillChangeContent called")
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
			tlPinAnnoView!.annotation = annotation as! MKPointAnnotation
		} else {
			tlPinAnnoView = TravelLocationPinAnnotationView(annotation: annotation as! MKPointAnnotation)
		}

		return tlPinAnnoView
	}

}

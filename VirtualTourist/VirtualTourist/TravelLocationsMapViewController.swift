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
//			static let NoPlacemarks      = "Did not receive any placemarks"
			static let TapDoneButton     = "Tap the Done button when finished"
			static let WhileInDeleteMode = "While in Pin Deletion Mode"
		}

		struct Title {
//			static let BadGeocode    = "Unable to geocode location"
			static let BadFetch      = "Unable to access app database"
			static let TapPins       = "Tap Pins to Delete"
			static let CannotDropPin = "Cannot Drop Pin"
		}

	}

	private struct SEL {
		static let TrashButtonTapped = #selector(TravelLocationsMapViewController.trashButtonWasTapped)
		static let DoneButtonTapped  = #selector(TravelLocationsMapViewController.doneButtonWasTapped)
	}

	// MARK: - Private Stored Variables

	private var inPinDeletionMode = false

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

		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: SEL.TrashButtonTapped)
		mapView.addGestureRecognizer(longPress)

		do {
			try frc.performFetch()

			for travelLocation in frc.fetchedObjects as! [VirtualTouristTravelLocation] {
				mapView.addAnnotation(travelLocation.pointAnnotation)
			}

		} catch let error as NSError {
			self.presentAlert(Alert.Title.BadFetch, message: error.localizedDescription)
		}

	}

	// MARK: - IB Actions

	@IBAction internal func handleLongPress(gesture: UIGestureRecognizer) {

		if inPinDeletionMode {
//			presentAlert(Alert.Title.CannotDropPin, message: Alert.Message.WhileInDeleteMode)
			return
		}

		if gesture.state == .Began {
			let coord = mapView.convertPoint(gesture.locationInView(mapView), toCoordinateFromView: mapView)
			_ = VirtualTouristTravelLocation(coordinate: coord, context: CoreDataManager.sharedManager.moc)
			CoreDataManager.sharedManager.saveContext()
		}

	}

	internal func doneButtonWasTapped() {
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: SEL.TrashButtonTapped)
		inPinDeletionMode = false
	}

	internal func trashButtonWasTapped() {
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: SEL.DoneButtonTapped)
		inPinDeletionMode = true
		presentAlert(Alert.Title.TapPins, message: Alert.Message.TapDoneButton)
	}

	// MARK: - NSFetchedResultsControllerDelegate

	internal func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {

		if type == .Insert {
			let travelLocation = anObject as! VirtualTouristTravelLocation
			mapView.addAnnotation(travelLocation.pointAnnotation)
		}
							
	}

	func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
	                atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
		return
	}

	func controllerDidChangeContent(controller: NSFetchedResultsController) {
		return
	}

	func controllerWillChangeContent(controller: NSFetchedResultsController) {
		return
	}

	// MARK: - MKMapViewDelegate

	internal func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
		assert(mapView == self.mapView, "Unexpected map view selecting an annotation")

		mapView.deselectAnnotation(view.annotation, animated: true)
		let tlpAnnotation = (view as? TravelLocationPinAnnotationView)!.annotation

		if inPinDeletionMode {
			mapView.removeAnnotation(tlpAnnotation!)

			if mapView.annotations.isEmpty {
				doneButtonWasTapped()
			}

			if let travelLocation = getTravelLocation(tlpAnnotation!.coordinate) {
				deleteAssociatedPhotos(travelLocation)
            CoreDataManager.sharedManager.moc.deleteObject(travelLocation)
				CoreDataManager.sharedManager.saveContext()
			}

		} else {
			let travelogueVC = self.storyboard?.instantiateViewControllerWithIdentifier(TravelogueViewController.UI.StoryboardID) as! TravelogueViewController

			travelogueVC.coordinate = tlpAnnotation!.coordinate
			navigationController?.pushViewController(travelogueVC, animated: true)
		}

	}

	internal func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
		assert(mapView == self.mapView, "Unexpected map view requesting view for annotation")

		var tlPinAnnoView = mapView.dequeueReusableAnnotationViewWithIdentifier(TravelLocationPinAnnotationView.UI.ReuseID) as? TravelLocationPinAnnotationView

		if let _ = tlPinAnnoView {
			tlPinAnnoView!.annotation = annotation as! MKPointAnnotation
		} else {
			tlPinAnnoView = TravelLocationPinAnnotationView(annotation: annotation as! MKPointAnnotation)
		}

		return tlPinAnnoView
	}

	// MARK: - Private

	private func deleteAssociatedPhotos(travelLocation: VirtualTouristTravelLocation)  {
		let photosFetchRequest = NSFetchRequest(entityName: VirtualTouristPhoto.Consts.EntityName)
		photosFetchRequest.sortDescriptors = [NSSortDescriptor(key: CoreDataManager.SortKey.Title, ascending: true)]
		photosFetchRequest.predicate = NSPredicate(format: CoreDataManager.Predicate.PhotosByLocation, travelLocation)

		do {
			let fetchedPhotos = try CoreDataManager.sharedManager.moc.executeFetchRequest(photosFetchRequest) as! [VirtualTouristPhoto]

			if !fetchedPhotos.isEmpty {

				for vtPhoto in fetchedPhotos {
					CoreDataManager.sharedManager.moc.deleteObject(vtPhoto)
				}

				CoreDataManager.sharedManager.saveContext()
			}

		} catch let error as NSError {
			self.presentAlert(Alert.Title.BadFetch, message: error.localizedDescription)
		}
		
	}
	
	private func getTravelLocation(coordinate: CLLocationCoordinate2D) -> VirtualTouristTravelLocation? {
		let fetchRequest = NSFetchRequest(entityName: VirtualTouristTravelLocation.Consts.EntityName)

		fetchRequest.sortDescriptors = []
		fetchRequest.predicate       = NSPredicate(format: CoreDataManager.Predicate.LocationByLatLong, coordinate.latitude, coordinate.longitude)

		do {
			let travelLocations = try CoreDataManager.sharedManager.moc.executeFetchRequest(fetchRequest) as! [VirtualTouristTravelLocation]

			if !travelLocations.isEmpty { return travelLocations[0] }
			else                        { return nil }

		} catch let error as NSError {
			self.presentAlert(Alert.Title.BadFetch, message: error.localizedDescription)
		}

		return nil
	}
	
}

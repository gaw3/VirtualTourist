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

	private struct SEL {
		static let TrashButtonTapped = #selector(TravelLocationsMapViewController.trashButtonWasTapped)
		static let DoneButtonTapped  = #selector(TravelLocationsMapViewController.doneButtonWasTapped)
	}

	private struct Predicate {
		static let ByLatLong = "latitude == %lf and longitude == %lf"
	}

	// MARK: - Private Stored Variables

	private var inPinDeletionMode = false

	// MARK: - Private Computed Variables

	lazy private var frc: NSFetchedResultsController = {
		let fetchRequest = NSFetchRequest(entityName: VirtualTouristTravelLocation.Consts.EntityName)
		fetchRequest.sortDescriptors = []

		let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataManager.sharedManager.moc, sectionNameKeyPath: nil, cacheName: nil)
		frc.delegate = self
		
		return frc
	}()

//	private func frcForAssociatedPhotos(travelLocation: VirtualTouristTravelLocation) -> NSFetchedResultsController {
//		let photosFetchRequest = NSFetchRequest(entityName: VirtualTouristPhoto.Consts.EntityName)
//		photosFetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
//		photosFetchRequest.predicate = NSPredicate(format: "location == %@", travelLocation)
//
//		let frc = NSFetchedResultsController(fetchRequest: photosFetchRequest, managedObjectContext: CoreDataManager.sharedManager.moc, sectionNameKeyPath: nil, cacheName: nil)
//		frc.delegate = self
//
//		return frc
//	}

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
			print("\(error)")
		}

	}

	// MARK: - IB Actions

	@IBAction internal func handleLongPress(gesture: UIGestureRecognizer) {

		if inPinDeletionMode { return }

		if gesture.state == .Began {
			let coord = mapView.convertPoint(gesture.locationInView(mapView), toCoordinateFromView: mapView)
			_ = VirtualTouristTravelLocation(coordinate: coord, context: CoreDataManager.sharedManager.moc)
			CoreDataManager.sharedManager.saveContext()
		}

	}

	internal func doneButtonWasTapped() {
		print("done button was tapped")
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: SEL.TrashButtonTapped)
		inPinDeletionMode = false
	}

	internal func trashButtonWasTapped() {
		print("trash button was tapped")
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: SEL.DoneButtonTapped)
		inPinDeletionMode = true
	}

	// MARK: - NSFetchedResultsControllerDelegate

	func controllerDidChangeContent(controller: NSFetchedResultsController) {
		print("controller DidChangeContent called")
	}

	func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {

		print("controller didChangeObject called")

		if type == .Insert {
			print("change = insert")
			let travelLocation = anObject as! VirtualTouristTravelLocation
			mapView.addAnnotation(travelLocation.pointAnnotation)
		} else if type == .Delete {
			print("change = delete")
//			let travelLocation = anObject as! VirtualTouristTravelLocation
//			mapView.removeAnnotation(travelLocation.pointAnnotation)
		} else if type == .Update {
			print("change = update")
		} else if type == .Move {
			print("change = move")
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

//	internal func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//
//		if control == view.rightCalloutAccessoryView {
//			let travelogueVC = self.storyboard?.instantiateViewControllerWithIdentifier(TravelogueViewController.UI.StoryboardID)
//									 as! TravelogueViewController
//
//			travelogueVC.tlPinAnnoView = view as? TravelLocationPinAnnotationView
//			navigationController?.pushViewController(travelogueVC, animated: true)
//		}
//
//	}

	internal func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
		print("mapView did select annotation view")

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
		print("mapView view for Annotation")
		var tlPinAnnoView = mapView.dequeueReusableAnnotationViewWithIdentifier(TravelLocationPinAnnotationView.UI.ReuseID) as? TravelLocationPinAnnotationView

		if let _ = tlPinAnnoView {
			tlPinAnnoView!.annotation = annotation as! MKPointAnnotation
		} else {
			tlPinAnnoView = TravelLocationPinAnnotationView(annotation: annotation as! MKPointAnnotation)
		}

		return tlPinAnnoView
	}

	private func getTravelLocation(coordinate: CLLocationCoordinate2D) -> VirtualTouristTravelLocation? {
		let fetchRequest = NSFetchRequest(entityName: VirtualTouristTravelLocation.Consts.EntityName)

		fetchRequest.sortDescriptors = []
		fetchRequest.predicate       = NSPredicate(format: Predicate.ByLatLong, coordinate.latitude, coordinate.longitude)

		do {
			let travelLocations = try CoreDataManager.sharedManager.moc.executeFetchRequest(fetchRequest) as! [VirtualTouristTravelLocation]

			if !travelLocations.isEmpty { return travelLocations[0] }
			else                        { return nil }

		} catch let error as NSError {
			print("\(error)")
		}

		return nil
	}
	
	private func deleteAssociatedPhotos(travelLocation: VirtualTouristTravelLocation)  {
		let photosFetchRequest = NSFetchRequest(entityName: VirtualTouristPhoto.Consts.EntityName)
		photosFetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
		photosFetchRequest.predicate = NSPredicate(format: "location == %@", travelLocation)

		do {
			let fetchedPhotos = try CoreDataManager.sharedManager.moc.executeFetchRequest(photosFetchRequest) as! [VirtualTouristPhoto]

			if !fetchedPhotos.isEmpty {

				for vtPhoto in fetchedPhotos {
					print("deleting from cache & core data:  \(vtPhoto.imageURLString)")
					CoreDataManager.sharedManager.moc.deleteObject(vtPhoto)
				}

				CoreDataManager.sharedManager.saveContext()
			}

		} catch let error as NSError {
			print("\(error)")
		}

	}

}

//
//  TravelogueViewController.swift
//  VirtualTourist
//
//  Created by Gregory White on 2/26/16.
//  Copyright © 2016 Gregory White. All rights reserved.
//

import CoreData
import MapKit
import UIKit

final internal class TravelogueViewController: UIViewController, NSFetchedResultsControllerDelegate {

	// MARK: - Internal Constants

	internal struct UI {
		static let StoryboardID = "TravelogueVC"
	}

	// MARK: - Private Constants

	private struct Layout {
		static let NumberOfCellsAcrossInPortrait:  CGFloat = 3.0
		static let NumberOfCellsAcrossInLandscape: CGFloat = 5.0
		static let MinimumInteritemSpacing:        CGFloat = 3.0
	}

	private struct Predicate {
		static let ByLatLong = "latitude == %lf and longitude == %lf"
	}

	// MARK: - Internal Stored Variables

	internal var tlPinAnnoView: TravelLocationPinAnnotationView? = nil
	internal var coordinate:    CLLocationCoordinate2D? = nil

	// MARK: - Private Stored Variables

	private var travelLocation: VirtualTouristTravelLocation? = nil
	private var selectedPhotos = [NSIndexPath]()

	// MARK: - Private Computed Variables

	lazy private var frc: NSFetchedResultsController = {
		let photosFetchRequest = NSFetchRequest(entityName: VirtualTouristPhoto.Consts.EntityName)
		photosFetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
		photosFetchRequest.predicate = NSPredicate(format: "location == %@", self.travelLocation!)

		let frc = NSFetchedResultsController(fetchRequest: photosFetchRequest, managedObjectContext: CoreDataManager.sharedManager.moc, sectionNameKeyPath: nil, cacheName: nil)
		frc.delegate = self

		return frc
	}()

	// MARK: - IB Outlets

	@IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
	@IBOutlet weak var toolbarButton: UIBarButtonItem!
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var mapView: MKMapView!

	// MARK: - View Events

	override internal func viewDidLoad() {
		super.viewDidLoad()

		initCollectionView()

		if let tl = getTravelLocation() {
			travelLocation = tl
			mapView.addAnnotation(travelLocation!.pointAnnotation)

			do {
				try frc.performFetch()
				
				if frc.fetchedObjects!.isEmpty {
					flickrClient.searchPhotosByLocation(travelLocation!, completionHandler: searchPhotosByLocationCompletionHandler)
				}
			} catch {
				print("Error performing fetch")
			}

		}

	}

	override internal func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()

		let numOfCellsAcross: CGFloat = UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation) ? Layout.NumberOfCellsAcrossInPortrait : Layout.NumberOfCellsAcrossInLandscape
		let itemWidth: CGFloat = (view.frame.size.width - (flowLayout.minimumInteritemSpacing * (numOfCellsAcross - 1))) / numOfCellsAcross

		flowLayout.itemSize = CGSizeMake(itemWidth, itemWidth) // yes, a square on purpose
	}

	// MARK: - IB Outlets

	@IBAction func toolbarButtonWasTapped(sender: UIBarButtonItem) {

		if toolbarButton.title == "New Collection" {

			for vtPhoto in frc.fetchedObjects as! [VirtualTouristPhoto] {
				print("deleting from cache & core data:  \(vtPhoto.imageURLString)")
				CoreDataManager.sharedManager.moc.deleteObject(vtPhoto)
			}

			CoreDataManager.sharedManager.saveContext()
			collectionView!.reloadData()
			flickrClient.searchPhotosByLocation(travelLocation!, completionHandler: searchPhotosByLocationCompletionHandler)
		} else {
			let vtPhotos = frc.fetchedObjects as! [VirtualTouristPhoto]

			for photoIndex in selectedPhotos {
				CoreDataManager.sharedManager.moc.deleteObject(vtPhotos[photoIndex.row])
			}

			CoreDataManager.sharedManager.saveContext()

			collectionView!.performBatchUpdates({() -> Void in
					self.collectionView!.deleteItemsAtIndexPaths(self.selectedPhotos)
				}, completion: nil)

			toolbarButton.title = "New Collection"
			selectedPhotos.removeAll()
		}

	}

	// MARK: - MKMapViewDelegate

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
	
	// MARK: - NSFetchedResultsControllerDelegate

	func controllerDidChangeContent(controller: NSFetchedResultsController) {
		print("controller DidChangeContent called")
	}

	func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
		print("controller didChangeObject called for change type = \(type.rawValue) indexPath = \(indexPath), newIndexPath = \(newIndexPath)")
	}

	func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
		atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
			print("controller didChangeSection called")
	}

	func controllerWillChangeContent(controller: NSFetchedResultsController) {
		print("controller WillChangeContent called")
	}

	// MARK: - UICollectionViewDataSource

	internal func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		assert(collectionView == self.collectionView, "Unexpected collection view reqesting cell of item at index path")
		print("collView cellForItemAtIndexPath")

		let cell = collectionView.dequeueReusableCellWithReuseIdentifier("TravelogueCollectionViewCell", forIndexPath: indexPath) as! TravelogueCollectionViewCell
		configureCell(cell, atIndexPath: indexPath)

		return cell
	}

	internal func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		assert(collectionView == self.collectionView, "Unexpected collection view reqesting number of items in section")

		let sectionInfo = frc.sections![section]
		print("number of items in section = \(sectionInfo.numberOfObjects)")

		collectionView.hidden = (sectionInfo.numberOfObjects == 0)
		return sectionInfo.numberOfObjects
	}

	internal func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		assert(collectionView == self.collectionView, "Unexpected collection view reqesting number of sections in view")
		print("number of sections in collection = \(frc.sections!.count)")
		return frc.sections?.count ?? 0
	}

	// MARK: - UICollectionViewDelegate

	internal func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		assert(collectionView == self.collectionView, "Unexpected collection view selected an item")
      print("collView didSelectItemAtIndexPath = \(indexPath)")

		let cell = collectionView.cellForItemAtIndexPath(indexPath) as! TravelogueCollectionViewCell

		if let index = selectedPhotos.indexOf(indexPath) {
			selectedPhotos.removeAtIndex(index)
			cell.imageView?.alpha = 1.0
			if selectedPhotos.isEmpty { toolbarButton.title = "New Collection" }
		} else {
			selectedPhotos.append(indexPath)
			cell.imageView?.alpha = 0.3
			toolbarButton.title = "Remove Selected Photos"
		}

	}
	
	// MARK: - Private:  Completion Handlers

	private func getRemoteImageWithURLStringCompletionHandler(URLString: String, cellForPhoto: TravelogueCollectionViewCell) -> APIDataTaskWithRequestCompletionHandler {

		return { (result, error) -> Void in

			guard error == nil else {
				self.presentAlert("Unable to obtain photos", message: error!.localizedDescription)
				return
			}

			guard result != nil else {
				self.presentAlert("Unable to obtain photos", message: "JSON data unavailable")
				return
			}

			let downloadedImage = result as! UIImage
			PhotoCache.sharedCache.storeImage(downloadedImage, withIdentifier: URLString)
			print("storing image in cache:  \(URLString)")

			dispatch_async(dispatch_get_main_queue(), {
				cellForPhoto.activityIndicator?.stopAnimating()
				cellForPhoto.imageView?.backgroundColor = UIColor.whiteColor()
				cellForPhoto.imageView?.image = downloadedImage
			})
			
		}

	}

	private var searchPhotosByLocationCompletionHandler: APIDataTaskWithRequestCompletionHandler {

		return { (result, error) -> Void in

			guard error == nil else {
				self.presentAlert("Unable to obtain photos", message: error!.localizedDescription)
				return
			}

			guard result != nil else {
				self.presentAlert("Unable to obtain photos", message: "JSON data unavailable")
				return
			}

			let responseData = FlickrPhotosResponseData(responseData: result as! JSONDictionary)

			guard responseData.isStatusOK else {
				self.presentAlert("Unable to obtain photos", message: "JSON data unavailable")
            return
			}

			dispatch_async(dispatch_get_main_queue(), {
				self.travelLocation?.perPage = responseData.perpage

				if responseData.photoArray.isEmpty {
					self.travelLocation?.page  = 0
//					self.collectionView.hidden = true
				} else {
					self.travelLocation?.page  = responseData.page
//					self.collectionView.hidden = false

					for photoResponseData in responseData.photoArray {
						print("saving vtPhoto in core data = \(photoResponseData.url_m)")
						let photo = VirtualTouristPhoto(responseData: photoResponseData, context: CoreDataManager.sharedManager.moc)
						photo.location = self.travelLocation!
					}

				}

				CoreDataManager.sharedManager.saveContext()
				self.collectionView?.reloadData()
			})

		}

	}

	// MARK: - Private

	private func configureCell(cell: TravelogueCollectionViewCell, atIndexPath: NSIndexPath) {
		let vtPhoto = frc.objectAtIndexPath(atIndexPath) as! VirtualTouristPhoto

		cell.imageView?.image = nil
		cell.imageView?.backgroundColor = UIColor.blueColor()
		cell.activityIndicator?.startAnimating()

		if let cachedImage = PhotoCache.sharedCache.imageWithIdentifier(vtPhoto.imageURLString) {
			print("retrieving from cache:  \(vtPhoto.imageURLString)")

			cell.activityIndicator?.stopAnimating()
			cell.imageView?.backgroundColor = UIColor.whiteColor()
			cell.imageView?.image = cachedImage
			return
		}

		print("downloading from Flickr:  \(vtPhoto.imageURLString)")
		let downloadTask = FlickrAPIClient.sharedClient.getRemotePhotoWithURLStringTask(vtPhoto.imageURLString, completionHandler: getRemoteImageWithURLStringCompletionHandler(vtPhoto.imageURLString, cellForPhoto: cell))
		cell.taskToCancelIfCellIsReused = downloadTask
	}
	
	private func getTravelLocation() -> VirtualTouristTravelLocation? {
		let fetchRequest = NSFetchRequest(entityName: VirtualTouristTravelLocation.Consts.EntityName)

		fetchRequest.sortDescriptors = []
		fetchRequest.predicate       = NSPredicate(format: Predicate.ByLatLong, coordinate!.latitude, coordinate!.longitude)

		do {
			let travelLocations = try CoreDataManager.sharedManager.moc.executeFetchRequest(fetchRequest) as! [VirtualTouristTravelLocation]

			if !travelLocations.isEmpty { return travelLocations[0] }
			else                        { return nil }

		} catch let error as NSError {
			print("\(error)")
		}

		return nil
	}

	private func initCollectionView() {
		collectionView?.backgroundColor = UIColor.whiteColor()

		flowLayout.minimumInteritemSpacing = Layout.MinimumInteritemSpacing
		flowLayout.minimumLineSpacing      = Layout.MinimumInteritemSpacing
	}

}



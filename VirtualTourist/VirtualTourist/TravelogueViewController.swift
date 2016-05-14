//
//  TravelogueViewController.swift
//  VirtualTourist
//
//  Created by Gregory White on 2/26/16.
//  Copyright © 2016 Gregory White. All rights reserved.
//

import CoreData
import CoreGraphics
import CoreLocation
import MapKit
import UIKit

final internal class TravelogueViewController: UIViewController, NSFetchedResultsControllerDelegate {

	// MARK: - Internal Constants

	internal struct UI {
		static let StoryboardID = "TravelogueVC"
	}

	// MARK: - Private Constants

	private struct Alert {

		struct Message {
			static let NoJSONData = "JSON data unavailable"
		}

		struct Title {
			static let BadFetch = "Unable to access app database"
         static let NoPhotos = "Unable to obtain photos"
		}

	}

	private struct Alpha {
		static let Full:                   CGFloat = 1.0
		static let ReducedForSelectedCell: CGFloat = 0.3
	}

	private struct Layout {
		static let NumberOfCellsAcrossInPortrait:  CGFloat = 3.0
		static let NumberOfCellsAcrossInLandscape: CGFloat = 5.0
		static let MinimumInteritemSpacing:        CGFloat = 3.0

		static let NoPhotosLabel = "This pin has no images."
	}

	// MARK: - Internal Stored Variables

	internal var tlPinAnnoView: TravelLocationPinAnnotationView? = nil
	internal var coordinate:    CLLocationCoordinate2D? = nil

	// MARK: - Private Stored Variables

	private var travelLocation: VirtualTouristTravelLocation? = nil
	private var selectedPhotos = [NSIndexPath]()
	private var noPhotosLevel: UILabel?

	// MARK: - Private Computed Variables

	lazy private var frc: NSFetchedResultsController = {
		let photosFetchRequest = NSFetchRequest(entityName: VirtualTouristPhoto.Consts.EntityName)
		photosFetchRequest.sortDescriptors = [NSSortDescriptor(key: CoreDataManager.SortKey.Title, ascending: true)]
		photosFetchRequest.predicate = NSPredicate(format: CoreDataManager.Predicate.PhotosByLocation, self.travelLocation!)

		let frc = NSFetchedResultsController(fetchRequest: photosFetchRequest, managedObjectContext: CoreDataManager.sharedManager.moc, sectionNameKeyPath: nil, cacheName: nil)
		frc.delegate = self

		return frc
	}()

	private var photoCache: PhotoCache {
		return PhotoCache.sharedCache
	}

	// MARK: - IB Outlets

	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var flowLayout:     UICollectionViewFlowLayout!
	@IBOutlet weak var mapView:        MKMapView!
	@IBOutlet weak var refreshButton:  UIBarButtonItem!
	@IBOutlet weak var trashButton:    UIBarButtonItem!

	// MARK: - View Events

	override internal func viewDidLoad() {
		super.viewDidLoad()

		initCollectionView()
		refreshButton.enabled = true
		trashButton.enabled   = false

		travelLocation = getTravelLocation()

		if travelLocation != nil {
			mapView.addAnnotation(travelLocation!.pointAnnotation)

			do {
				try frc.performFetch()
				
				if frc.fetchedObjects!.isEmpty {
					flickrClient.searchPhotosByLocation(travelLocation!, completionHandler: searchPhotosByLocationCompletionHandler)
				}

			} catch let error as NSError {
				self.presentAlert(Alert.Title.BadFetch, message: error.localizedDescription)
			}

		}

	}

	override internal func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)

		noPhotosLevel!.center = (collectionView?.backgroundView?.center)!
		noPhotosLevel!.hidden = false
	}

	// MARK: - IB Outlets

	@IBAction func refreshButtonWasTapped(sender: UIBarButtonItem) {
		getNewCollection()
	}

	@IBAction func trashButtonWasTapped(sender: UIBarButtonItem) {
		deleteSelectedPhotos()
	}

	// MARK: - MKMapViewDelegate

	internal func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
		var tlPinAnnoView = mapView.dequeueReusableAnnotationViewWithIdentifier(TravelLocationPinAnnotationView.UI.ReuseID) as? TravelLocationPinAnnotationView

		if let _ = tlPinAnnoView {
			tlPinAnnoView!.annotation = annotation as! MKPointAnnotation
		} else {
			tlPinAnnoView = TravelLocationPinAnnotationView(annotation: annotation as! MKPointAnnotation)
		}

		return tlPinAnnoView
	}
	
	// MARK: - NSFetchedResultsControllerDelegate

	func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
		return
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

	// MARK: - UICollectionViewDataSource

	internal func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		assert(collectionView == self.collectionView, "Unexpected collection view reqesting cell of item at index path")

		let cell = collectionView.dequeueReusableCellWithReuseIdentifier(TravelogueCollectionViewCell.UI.ReuseID, forIndexPath: indexPath) as! TravelogueCollectionViewCell
		configureCell(cell, atIndexPath: indexPath)

		return cell
	}

	internal func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		assert(collectionView == self.collectionView, "Unexpected collection view reqesting number of items in section")

		let sectionInfo = frc.sections![section]
		return sectionInfo.numberOfObjects
	}

	internal func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		assert(collectionView == self.collectionView, "Unexpected collection view reqesting number of sections in view")

		return frc.sections?.count ?? 0
	}

	// MARK: - UICollectionViewDelegate

	internal func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		assert(collectionView == self.collectionView, "Unexpected collection view selected an item")

		let cell = collectionView.cellForItemAtIndexPath(indexPath) as! TravelogueCollectionViewCell

		if let index = selectedPhotos.indexOf(indexPath) {
			selectedPhotos.removeAtIndex(index)
			cell.imageView?.alpha = Alpha.Full

			if selectedPhotos.isEmpty {
				trashButton.enabled   = false
				refreshButton.enabled = true
			}

		} else {
			selectedPhotos.append(indexPath)
			cell.imageView?.alpha = Alpha.ReducedForSelectedCell
			trashButton.enabled   = true
			refreshButton.enabled = false
		}

	}
	
	// MARK: - Private:  Completion Handlers

	private func getRemoteImageCompletionHandler(vtPhoto: VirtualTouristPhoto, cellForPhoto: TravelogueCollectionViewCell) -> APIDataTaskWithRequestCompletionHandler {

		return { (result, error) -> Void in

			guard error == nil else {
				self.presentAlert(Alert.Title.NoPhotos, message: error!.localizedDescription)
				return
			}

			guard result != nil else {
				self.presentAlert(Alert.Title.NoPhotos, message: Alert.Message.NoJSONData)
				return
			}

			let downloadedImage = result as! UIImage
			self.photoCache.storeImage(downloadedImage, withCacheID: vtPhoto.fileName)

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
				self.presentAlert(Alert.Title.NoPhotos, message: error!.localizedDescription)
				return
			}

			guard result != nil else {
				self.presentAlert(Alert.Title.NoPhotos, message: Alert.Message.NoJSONData)
				return
			}

			let responseData = FlickrPhotosResponseData(responseData: result as! JSONDictionary)

			guard responseData.isStatusOK else {
				self.presentAlert(Alert.Title.NoPhotos, message: Alert.Message.NoJSONData)
            return
			}

			dispatch_async(dispatch_get_main_queue(), {
				self.travelLocation?.perPage = responseData.perpage

				if responseData.photoArray.isEmpty {
					self.collectionView?.backgroundView?.hidden = false
					self.travelLocation?.page = 0
				} else {
					self.collectionView?.backgroundView?.hidden = true
					self.travelLocation?.page = responseData.page

					for photoResponseData in responseData.photoArray {
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

		cell.imageView?.image           = nil
		cell.imageView?.backgroundColor = UIColor.blueColor()
		cell.imageView?.alpha           = Alpha.Full
		cell.activityIndicator?.startAnimating()

		if let cachedImage = photoCache.imageWithCacheID(vtPhoto.fileName) {
			cell.activityIndicator?.stopAnimating()
			cell.imageView?.backgroundColor = UIColor.whiteColor()
			cell.imageView?.image           = cachedImage
			return
		}

		let downloadTask = flickrClient.getRemotePhoto(vtPhoto, completionHandler: getRemoteImageCompletionHandler(vtPhoto, cellForPhoto: cell))
		cell.taskToCancelIfCellIsReused = downloadTask
	}

	private func deleteSelectedPhotos() {
		let vtPhotos = frc.fetchedObjects as! [VirtualTouristPhoto]

		for photoIndex in selectedPhotos {
			CoreDataManager.sharedManager.moc.deleteObject(vtPhotos[photoIndex.row])
		}

		CoreDataManager.sharedManager.saveContext()

		collectionView!.performBatchUpdates({() -> Void in
			self.collectionView!.deleteItemsAtIndexPaths(self.selectedPhotos)
			}, completion: nil)

		trashButton.enabled   = false
		refreshButton.enabled = true
		
		selectedPhotos.removeAll()
	}

	private func getNewCollection() {

		for vtPhoto in frc.fetchedObjects as! [VirtualTouristPhoto] {
			CoreDataManager.sharedManager.moc.deleteObject(vtPhoto)
		}

		CoreDataManager.sharedManager.saveContext()
		collectionView!.reloadData()
		flickrClient.searchPhotosByLocation(travelLocation!, completionHandler: searchPhotosByLocationCompletionHandler)
	}

	private func getTravelLocation() -> VirtualTouristTravelLocation? {
		let fetchRequest = NSFetchRequest(entityName: VirtualTouristTravelLocation.Consts.EntityName)

		fetchRequest.sortDescriptors = []
		fetchRequest.predicate       = NSPredicate(format: CoreDataManager.Predicate.LocationByLatLong, coordinate!.latitude, coordinate!.longitude)

		do {
			let travelLocations = try CoreDataManager.sharedManager.moc.executeFetchRequest(fetchRequest) as! [VirtualTouristTravelLocation]

			if !travelLocations.isEmpty { return travelLocations[0] }
			else                        { return nil }

		} catch let error as NSError {
			self.presentAlert(Alert.Title.BadFetch, message: error.localizedDescription)
		}

		return nil
	}

	private func initCollectionView() {
		noPhotosLevel = UILabel(frame: CGRectMake(0, 0, 200, 21))
		noPhotosLevel!.text          = Layout.NoPhotosLabel
		noPhotosLevel!.textColor     = UIColor.blackColor()
		noPhotosLevel!.textAlignment = .Center
		noPhotosLevel!.hidden        = true

		collectionView.backgroundColor = UIColor.whiteColor()

		collectionView?.backgroundView = UIView(frame: CGRectZero)
		collectionView?.backgroundView?.backgroundColor     = UIColor.whiteColor()
		collectionView?.backgroundView?.autoresizesSubviews = true
		collectionView?.backgroundView?.hidden              = true
		collectionView?.backgroundView?.addSubview(noPhotosLevel!)

		let numOfCellsAcross: CGFloat = Layout.NumberOfCellsAcrossInPortrait
		let itemWidth:        CGFloat = (view.frame.size.width - (flowLayout.minimumInteritemSpacing * (numOfCellsAcross - 1))) / numOfCellsAcross

		flowLayout.itemSize                = CGSizeMake(itemWidth, itemWidth) // yes, a square on purpose
		flowLayout.minimumInteritemSpacing = Layout.MinimumInteritemSpacing
		flowLayout.minimumLineSpacing      = Layout.MinimumInteritemSpacing
		flowLayout.sectionInset            = UIEdgeInsetsZero
	}

}



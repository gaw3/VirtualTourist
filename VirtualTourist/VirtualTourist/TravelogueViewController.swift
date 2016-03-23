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

final internal class TravelogueViewController: UICollectionViewController, NSFetchedResultsControllerDelegate {

	// MARK: - Internal Constants

	private struct Layout {
		static let NumberOfCellsAcrossInPortrait:  CGFloat = 3.0
		static let NumberOfCellsAcrossInLandscape: CGFloat = 5.0
		static let MinimumInteritemSpacing:        CGFloat = 3.0
	}

	internal struct UI {
		static let StoryboardID = "TravelogueVC"
		static let CollectionCellReuseID = "VTPhotoCollectionViewCell"
	}

	private struct Predicate {
		static let ByLatLong = "latitude == %lf and longitude == %lf"
	}

	// MARK: - Internal Stored Variables

	internal var tlPinAnnoView: TravelLocationPinAnnotationView? = nil
	internal var coordinate:    CLLocationCoordinate2D? = nil

	private var  travelLocation: VirtualTouristTravelLocation? = nil

	// MARK: - Private Computed Variables

	lazy private var frc: NSFetchedResultsController = {
		print("building the fetched results controller")
		let photosFetchRequest = NSFetchRequest(entityName: VirtualTouristPhoto.Consts.EntityName)
		photosFetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
		photosFetchRequest.predicate = NSPredicate(format: "location == %@", self.travelLocation!)

		let frc = NSFetchedResultsController(fetchRequest: photosFetchRequest, managedObjectContext: CoreDataManager.sharedManager.moc, sectionNameKeyPath: nil, cacheName: nil)
		frc.delegate = self

		return frc
	}()

	// MARK: - IB Outlets

	@IBOutlet weak var flowLayout: UICollectionViewFlowLayout!

	// MARK: - View Events

	override internal func viewDidLoad() {
		super.viewDidLoad()

		collectionView?.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: UI.CollectionCellReuseID)
		collectionView?.backgroundColor = UIColor.whiteColor()

		flowLayout.minimumInteritemSpacing = Layout.MinimumInteritemSpacing
		flowLayout.minimumLineSpacing      = Layout.MinimumInteritemSpacing

		let fetchRequest = NSFetchRequest(entityName: VirtualTouristTravelLocation.Consts.EntityName)
		fetchRequest.sortDescriptors = []
		fetchRequest.predicate       = NSPredicate(format: Predicate.ByLatLong, coordinate!.latitude, coordinate!.longitude)

		do {
			let travelLocations = try CoreDataManager.sharedManager.moc.executeFetchRequest(fetchRequest) as! [VirtualTouristTravelLocation]

			if travelLocations.isEmpty {
				// then we have a software error - this shouldn't happen
			} else {
				travelLocation = travelLocations[0]
				do {
					try frc.performFetch()
					if frc.fetchedObjects!.isEmpty {
						print("no photos associated with location in core data")
						flickrClient.searchPhotosByLocation(coordinate!, completionHandler: searchPhotosByLocationCompletionHandler)
					} else {
						print("photos already in core data")
						for photo in frc.fetchedObjects as! [VirtualTouristPhoto] {
							print("photo title = \(photo.title);  path = \(photo.imageURLString)")
						}

					}
				} catch {
					print("Error performing fetch")
				}

			}

		} catch let error as NSError {
			print("\(error)")
		}

	}

	override internal func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()

		let numOfCellsAcross: CGFloat = UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation) ? Layout.NumberOfCellsAcrossInPortrait : Layout.NumberOfCellsAcrossInLandscape
		let itemWidth: CGFloat = (view.frame.size.width - (flowLayout.minimumInteritemSpacing * (numOfCellsAcross - 1))) / numOfCellsAcross

		flowLayout.itemSize = CGSizeMake(itemWidth, itemWidth) // yes, a square on purpose
	}

	// MARK: - NSFetchedResultsControllerDelegate

	func controllerDidChangeContent(controller: NSFetchedResultsController) {
		print("controller DidChangeContent called")
//		collectionView?.reloadData()
	}

	func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
		print("controller didChangeObject called")
	}

	func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
		atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
			print("controller didChangeSection called")
	}

	func controllerWillChangeContent(controller: NSFetchedResultsController) {
		print("controller WillChangeContent called")
	}

	// MARK: - UICollectionViewDataSource

	override internal func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		assert(collectionView == self.collectionView, "Unexpected collection view reqesting cell of item at index path")
		print("collView cellForItemAtIndexPath")

		let cell = collectionView.dequeueReusableCellWithReuseIdentifier(UI.CollectionCellReuseID, forIndexPath: indexPath)

		cell.backgroundColor = UIColor.blueColor()

		return cell
	}

	override internal func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		assert(collectionView == self.collectionView, "Unexpected collection view reqesting number of items in section")
		print("collView numberOfItemsInSection")

		let sectionInfo = frc.sections![section]

		print("number Of Cells: \(sectionInfo.numberOfObjects)")
		return sectionInfo.numberOfObjects
	}

	override internal func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		assert(collectionView == self.collectionView, "Unexpected collection view reqesting number of sections in view")
		print("numberOfSectionsInCollectionView")

		return frc.sections?.count ?? 0
	}

	// MARK: - UICollectionViewDelegate

	override internal func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		assert(collectionView == self.collectionView, "Unexpected collection view selected an item")
      print("collView didSelectItemAtIndexPath")
	}
	
	// MARK: - Private:  Completion Handlers as Computed Variables

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
				self.travelLocation?.page    = responseData.page
				self.travelLocation?.perPage = responseData.perpage

				print("adding photos to core data")
				for photoResponseData in responseData.photoArray {
					let photo = VirtualTouristPhoto(responseData: photoResponseData, context: CoreDataManager.sharedManager.moc)
					photo.location = self.travelLocation!
					print("photo title = \(photo.title);  path = \(photo.imageURLString)")
				}

				CoreDataManager.sharedManager.saveContext()
				self.collectionView?.reloadData()
			})

		}

	}

}



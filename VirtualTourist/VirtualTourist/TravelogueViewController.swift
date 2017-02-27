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

final class TravelogueViewController: UIViewController {
        
    // MARK: - IB Outlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout:     UICollectionViewFlowLayout!
    @IBOutlet weak var mapView:        MKMapView!
    @IBOutlet weak var refreshButton:  UIBarButtonItem!
    @IBOutlet weak var trashButton:    UIBarButtonItem!
    
    // MARK: - IB Actions
    
    @IBAction func refreshButtonWasTapped(_ sender: UIBarButtonItem) {
        getNewCollection()
    }
    
    @IBAction func trashButtonWasTapped(_ sender: UIBarButtonItem) {
        deleteSelectedPhotos()
    }
    
    // MARK: - Variables
    
    var tlPinAnnoView: TravelLocationPinAnnotationView? = nil
    var coordinate:    CLLocationCoordinate2D? = nil
    
    fileprivate var travelLocation: VirtualTouristTravelLocation? = nil
    fileprivate var selectedPhotos = [IndexPath]()
    fileprivate var noPhotosLevel: UILabel?
    
    lazy fileprivate var frc: NSFetchedResultsController<NSFetchRequestResult> = {
        let photosFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: VirtualTouristPhoto.Entity.Name)
        photosFetchRequest.sortDescriptors = [NSSortDescriptor(key: CoreDataManager.SortKey.Title, ascending: true)]
        photosFetchRequest.predicate = NSPredicate(format: CoreDataManager.Predicate.PhotosByLocation, self.travelLocation!)
        
        let frc = NSFetchedResultsController<NSFetchRequestResult>(fetchRequest: photosFetchRequest, managedObjectContext: CoreDataManager.shared.moc, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        
        return frc
    }()
    
    // MARK: - View Events
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        noPhotosLevel!.center = (collectionView?.backgroundView?.center)!
        noPhotosLevel!.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initCollectionView()
        refreshButton.isEnabled = true
        trashButton.isEnabled   = false
        
        travelLocation = getTravelLocation()
        
        if travelLocation != nil {
            mapView.addAnnotation(travelLocation!.pointAnnotation)
            
            do {
                try frc.performFetch()
                
                if frc.fetchedObjects!.isEmpty {
                    FlickrAPIClient.shared.searchPhotos(at: travelLocation!, completionHandler: finishSearchingPhotosByLocation)
                }
                
            } catch let error as NSError {
                self.presentAlert(Alert.Title.BadFetch, message: error.localizedDescription)
            }
            
        }
        
    }
    
}



// MARK: -
// MARK: - Collection View Data Source

extension TravelogueViewController {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAtIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        assert(collectionView == self.collectionView, "Unexpected collection view reqesting cell of item at index path")
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IB.ReuseID.TravelogueCollectionViewCell, for: indexPath) as! TravelogueCollectionViewCell
        configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        assert(collectionView == self.collectionView, "Unexpected collection view reqesting number of items in section")
        
        let sectionInfo = frc.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func numberOfSectionsInCollectionView(_ collectionView: UICollectionView) -> Int {
        assert(collectionView == self.collectionView, "Unexpected collection view reqesting number of sections in view")
        
        return frc.sections?.count ?? 0
    }
    
}



// MARK: -
// MARK: - Collection View Delegate

extension TravelogueViewController {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: IndexPath) {
        assert(collectionView == self.collectionView, "Unexpected collection view selected an item")
        
        let cell = collectionView.cellForItem(at: indexPath) as! TravelogueCollectionViewCell
        
        if let index = selectedPhotos.index(of: indexPath) {
            selectedPhotos.remove(at: index)
            cell.imageView?.alpha = Alpha.Full
            
            if selectedPhotos.isEmpty {
                trashButton.isEnabled   = false
                refreshButton.isEnabled = true
            }
            
        } else {
            selectedPhotos.append(indexPath)
            cell.imageView?.alpha = Alpha.ReducedForSelectedCell
            trashButton.isEnabled   = true
            refreshButton.isEnabled = false
        }
        
    }
    
}



// MARK: -
// MARK: - Fetched Results Controller Delegate

extension TravelogueViewController: NSFetchedResultsControllerDelegate  {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        return
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        return
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        return
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        return
    }
    
}



// MARK: -
// MARK: - Map View Delegate

extension TravelogueViewController {
    
    func mapView(_ mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        var tlPinAnnoView = mapView.dequeueReusableAnnotationView(withIdentifier: IB.ReuseID.TravelLocsPinAnnoView) as? TravelLocationPinAnnotationView
        
        if let _ = tlPinAnnoView {
            tlPinAnnoView!.annotation = annotation as! MKPointAnnotation
        } else {
            tlPinAnnoView = TravelLocationPinAnnotationView(annotation: annotation as! MKPointAnnotation)
        }
        
        return tlPinAnnoView
    }
    
}



// MARK: -
// MARK: - Private Completion Handlers

private extension TravelogueViewController {
    
    func finishDownloadingPhoto(_ vtPhoto: VirtualTouristPhoto, cellForPhoto: TravelogueCollectionViewCell) -> DataTaskWithRequestCompletionHandler {
        
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
            PhotoCache.shared.storeImage(downloadedImage, withCacheID: vtPhoto.fileName)
            
            DispatchQueue.main.async(execute: {
                cellForPhoto.activityIndicator?.stopAnimating()
                cellForPhoto.imageView?.backgroundColor = UIColor.white
                cellForPhoto.imageView?.image = downloadedImage
            })
            
        }
        
    }
    
    var finishSearchingPhotosByLocation: DataTaskWithRequestCompletionHandler {
        
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
            
            DispatchQueue.main.async(execute: {
                self.travelLocation?.perPage = NSNumber(value: responseData.perpage)
                
                if responseData.photoArray.isEmpty {
                    self.collectionView?.backgroundView?.isHidden = false
                    self.travelLocation?.page = 0
                } else {
                    self.collectionView?.backgroundView?.isHidden = true
                    self.travelLocation?.page = NSNumber(value: responseData.page)
                    
                    for photoResponseData in responseData.photoArray {
                        let photo = VirtualTouristPhoto(responseData: photoResponseData, context: CoreDataManager.shared.moc)
                        photo.location = self.travelLocation!
                    }
                    
                }
                
                CoreDataManager.shared.saveContext()
                self.collectionView?.reloadData()
            })
            
        }
        
    }
    
}



// MARK: -
// MARK: - Private Helpers

private extension TravelogueViewController {
    
    struct Alpha {
        static let Full:                   CGFloat = 1.0
        static let ReducedForSelectedCell: CGFloat = 0.3
    }
    
    struct Layout {
        static let NumberOfCellsAcrossInPortrait:  CGFloat = 3.0
        static let NumberOfCellsAcrossInLandscape: CGFloat = 5.0
        static let MinimumInteritemSpacing:        CGFloat = 3.0
        
        static let NoPhotosLabel = "This pin has no images."
    }
    
    func configureCell(_ cell: TravelogueCollectionViewCell, atIndexPath: IndexPath) {
        let vtPhoto = frc.object(at: atIndexPath) as! VirtualTouristPhoto
        
        cell.imageView?.image           = nil
        cell.imageView?.backgroundColor = UIColor.blue
        cell.imageView?.alpha           = Alpha.Full
        cell.activityIndicator?.startAnimating()
        
        if let cachedImage = PhotoCache.shared.image(withCacheID: vtPhoto.fileName) {
            cell.activityIndicator?.stopAnimating()
            cell.imageView?.backgroundColor = UIColor.white
            cell.imageView?.image           = cachedImage
            return
        }
        
        let downloadTask = FlickrAPIClient.shared.downloadPhoto(vtPhoto, completionHandler: finishDownloadingPhoto(vtPhoto, cellForPhoto: cell))
        cell.taskToCancelIfCellIsReused = downloadTask
    }
    
    func deleteSelectedPhotos() {
        let vtPhotos = frc.fetchedObjects as! [VirtualTouristPhoto]
        
        for photoIndex in selectedPhotos {
            CoreDataManager.shared.moc.delete(vtPhotos[photoIndex.row])
        }
        
        CoreDataManager.shared.saveContext()
        
        collectionView!.performBatchUpdates({() -> Void in
            self.collectionView!.deleteItems(at: self.selectedPhotos)
        }, completion: nil)
        
        trashButton.isEnabled   = false
        refreshButton.isEnabled = true
        
        selectedPhotos.removeAll()
    }
    
    func getNewCollection() {
        
        for vtPhoto in frc.fetchedObjects as! [VirtualTouristPhoto] {
            CoreDataManager.shared.moc.delete(vtPhoto)
        }
        
        CoreDataManager.shared.saveContext()
        collectionView!.reloadData()
        FlickrAPIClient.shared.searchPhotos(at: travelLocation!, completionHandler: finishSearchingPhotosByLocation)
    }
    
    func getTravelLocation() -> VirtualTouristTravelLocation? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: VirtualTouristTravelLocation.Entity.Name)
        
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate       = NSPredicate(format: CoreDataManager.Predicate.LocationByLatLong, coordinate!.latitude, coordinate!.longitude)
        
        do {
            let travelLocations = try CoreDataManager.shared.moc.fetch(fetchRequest) as! [VirtualTouristTravelLocation]
            
            if !travelLocations.isEmpty { return travelLocations[0] }
            else                        { return nil }
            
        } catch let error as NSError {
            self.presentAlert(Alert.Title.BadFetch, message: error.localizedDescription)
        }
        
        return nil
    }
    
    func initCollectionView() {
        noPhotosLevel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        noPhotosLevel!.text          = Layout.NoPhotosLabel
        noPhotosLevel!.textColor     = UIColor.black
        noPhotosLevel!.textAlignment = .center
        noPhotosLevel!.isHidden        = true
        
        collectionView.backgroundColor = UIColor.white
        
        collectionView?.backgroundView = UIView(frame: CGRect.zero)
        collectionView?.backgroundView?.backgroundColor     = UIColor.white
        collectionView?.backgroundView?.autoresizesSubviews = true
        collectionView?.backgroundView?.isHidden              = true
        collectionView?.backgroundView?.addSubview(noPhotosLevel!)
        
        let numOfCellsAcross: CGFloat = Layout.NumberOfCellsAcrossInPortrait
        let itemWidth:        CGFloat = (view.frame.size.width - (flowLayout.minimumInteritemSpacing * (numOfCellsAcross - 1))) / numOfCellsAcross
        
        flowLayout.itemSize                = CGSize(width: itemWidth, height: itemWidth) // yes, a square on purpose
        flowLayout.minimumInteritemSpacing = Layout.MinimumInteritemSpacing
        flowLayout.minimumLineSpacing      = Layout.MinimumInteritemSpacing
        flowLayout.sectionInset            = UIEdgeInsets.zero
    }

}




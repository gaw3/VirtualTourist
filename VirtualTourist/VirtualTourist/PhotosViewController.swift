//
//  PhotosViewController.swift
//  VirtualTourist
//
//  Created by Gregory White on 4/14/20.
//  Copyright © 2020 Gregory White. All rights reserved.
//

import MapKit
import UIKit

final class PhotosViewController: UIViewController {

    // MARK: - IB Outlets

    @IBOutlet weak var photosCollection: UICollectionView!
    @IBOutlet weak var flowLayout:       UICollectionViewFlowLayout!
    @IBOutlet weak var map:              MKMapView!
    
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var trashButton:   UIBarButtonItem!
    
    // MARK: - IB Actions

    @IBAction func didTap(_ barButtonItem: UIBarButtonItem) {
        
        switch barButtonItem {
            
        case refreshButton:
            refreshButton.isEnabled = false
            workflow?.getListOfPhotos(forLocation: location)

        case trashButton:
            deleteSelectedPhotos()
            
        default:
            assertionFailure("rcvd tap event for unknown button")
            
        }
        
    }
    
    // MARK: - Variables

    var location: VTLocation!
    
    private var vtPhotos: [VTPhoto]!
    private var noPhotosLabel: UILabel!
    private var workflow: GetListOfPhotosWorkflow?

    // MARK: - View Events

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        map.addAnnotation(location.annotation)
        map.setRegion(location.annotation.region, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initCollectionView()
        
        refreshButton.isEnabled = true
        trashButton.isEnabled   = false
        
        let sortByID = NSSortDescriptor(key: "id", ascending: true)
        vtPhotos = location.photos?.sortedArray(using: [sortByID]) as? [VTPhoto]
        
        workflow = GetListOfPhotosWorkflow(delegate: self)
    }
    
}



// MARK: -
// MARK: - Collection View Data Source

extension PhotosViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String.ReuseID.photoCell, for: indexPath) as! PhotoCell
        
        cell.configure(withPhoto: vtPhotos[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return vtPhotos.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
}



// MARK: -
// MARK: - Collection View Delegate

extension PhotosViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoCell
        
        cell.imageView.alpha = 1.0
        
        if collectionView.indexPathsForSelectedItems!.count == 0 {
            trashButton.isEnabled   = false
            refreshButton.isEnabled = true
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoCell
        
        cell.imageView.alpha    = 0.3
        trashButton.isEnabled   = true
        refreshButton.isEnabled = false
    }

}



// MARK: -
// MARK: - Core Data Update Delegate

extension PhotosViewController: CoreDataUpdateDelegate {
    
    func updated(_ location: VTLocation) {
        
        DispatchQueue.main.async(execute: {
            let sortByID  = NSSortDescriptor(key: "id", ascending: true)
            self.vtPhotos = location.photos?.sortedArray(using: [sortByID]) as? [VTPhoto]
            self.photosCollection.reloadData()
            self.photosCollection.backgroundView?.isHidden = !self.vtPhotos.isEmpty
            self.refreshButton.isEnabled = true
        })
        
    }
    
}



// MARK: -
// MARK: - Get List Of Photos Delegate

extension PhotosViewController: GetListOfPhotosWorkflowDelegate {
    
    func process(_ response: GetListOfPhotosResponse, forLocation location: VTLocation) {
        coreData.update(location, withResponse: response, delegate: self)
    }
    
}



// MARK: -
// MARK: - Map View Delegate

extension PhotosViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let marker = mapView.dequeueReusableAnnotationView(withIdentifier: String.ReuseID.markerAnnoView) as? MKMarkerAnnotationView ??
                     MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: String.ReuseID.markerAnnoView)

        marker.canShowCallout    = false
        marker.animatesWhenAdded = true
        marker.glyphText         = "🚀"
        marker.markerTintColor   = .blue

        return marker
    }
    
}



// MARK: -
// MARK: - Private Helpers

private extension PhotosViewController {
    
    enum Layout {
        static let numberOfCellsAcrossInPortrait  = CGFloat(3.0)
        static let numberOfCellsAcrossInLandscape = CGFloat(5.0)
        static let minimumInteritemSpacing        = CGFloat(3.0)
    }
    
    func deleteSelectedPhotos() {
        
        for indexPath in photosCollection.indexPathsForSelectedItems! {
            coreData.delete(vtPhoto: vtPhotos[indexPath.row])
        }
        
        let sortByID  = NSSortDescriptor(key: "id", ascending: true)
        vtPhotos = location.photos?.sortedArray(using: [sortByID]) as? [VTPhoto]
        
        photosCollection.performBatchUpdates({
            self.photosCollection.deleteItems(at: self.photosCollection.indexPathsForSelectedItems!)
        }) { (flag) in
            print("flag = \(flag)")
            self.trashButton.isEnabled   = false
            self.refreshButton.isEnabled = true
            self.photosCollection.backgroundView?.isHidden = !self.vtPhotos.isEmpty
        }
        
    }

    func initCollectionView() {
        let label = UILabel()
        
        label.text          = "No more photos"
        label.textColor     = .black
        label.textAlignment = .center
        
        photosCollection.backgroundView           = label
        photosCollection.backgroundView?.isHidden = true
        photosCollection.allowsMultipleSelection  = true
        
        let numOfCellsAcross: CGFloat = Layout.numberOfCellsAcrossInPortrait
        let itemWidth:        CGFloat = (view.frame.size.width - (Layout.minimumInteritemSpacing * (numOfCellsAcross - 1))) / numOfCellsAcross
        
        flowLayout.itemSize                = CGSize(width: itemWidth, height: itemWidth) // yes, a square on purpose
        flowLayout.minimumInteritemSpacing = Layout.minimumInteritemSpacing
        flowLayout.minimumLineSpacing      = Layout.minimumInteritemSpacing
        flowLayout.sectionInset            = .zero
    }
    
}

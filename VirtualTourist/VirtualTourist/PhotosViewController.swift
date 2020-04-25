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

    @IBOutlet weak var photosCollection: UICollectionView!
    @IBOutlet weak var flowLayout:       UICollectionViewFlowLayout!
    @IBOutlet weak var map:              MKMapView!
    
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var trashButton:   UIBarButtonItem!
    
    @IBAction func didTap(_ barButtonItem: UIBarButtonItem) {
        
        switch barButtonItem {
            
        case refreshButton:
            refreshButton.isEnabled = false
            workflow?.getListOfPhotos(forLocation: location)

        case trashButton:   print("trash button tapped")
        default: assertionFailure("rcvd tap event for unknown button")
        }
        
    }
    
    var location: VTLocation!
    
    private var vtPhotos: [VTPhoto]!
    private var noPhotosLabel: UILabel!
    private var workflow: GetListOfPhotosWorkflow?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initCollectionView()
        
        refreshButton.isEnabled = true
        trashButton.isEnabled   = false
        
        let sortByID = NSSortDescriptor(key: "id", ascending: true)
        vtPhotos = location.photos?.sortedArray(using: [sortByID]) as? [VTPhoto]
        
        workflow = GetListOfPhotosWorkflow(delegate: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        map.addAnnotation(location.annotation)
        map.setRegion(location.annotation.region, animated: true)
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
// MARK: - Core Data Update Delegate

extension PhotosViewController: CoreDataUpdateDelegate {
    
    func updated(_ location: VTLocation) {
        
        DispatchQueue.main.async(execute: {
            let sortByID  = NSSortDescriptor(key: "id", ascending: true)
            self.vtPhotos = location.photos?.sortedArray(using: [sortByID]) as? [VTPhoto]
            self.photosCollection.reloadData()
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
        
        static let noPhotosLabel = "This location has no images."
    }

    func initCollectionView() {
        noPhotosLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        noPhotosLabel.text          = Layout.noPhotosLabel
        noPhotosLabel.textColor     = .black
        noPhotosLabel.textAlignment = .center
        noPhotosLabel.isHidden      = true
        
        photosCollection.backgroundColor = .white
        
        photosCollection.backgroundView = UIView(frame: .zero)
        photosCollection.backgroundView?.backgroundColor     = .white
        photosCollection.backgroundView?.autoresizesSubviews = true
        photosCollection.backgroundView?.isHidden            = true
        photosCollection.backgroundView?.addSubview(noPhotosLabel)
        
        let numOfCellsAcross: CGFloat = Layout.numberOfCellsAcrossInPortrait
        let itemWidth:        CGFloat = (view.frame.size.width - (Layout.minimumInteritemSpacing * (numOfCellsAcross - 1))) / numOfCellsAcross
        
        flowLayout.itemSize                = CGSize(width: itemWidth, height: itemWidth) // yes, a square on purpose
        flowLayout.minimumInteritemSpacing = Layout.minimumInteritemSpacing
        flowLayout.minimumLineSpacing      = Layout.minimumInteritemSpacing
        flowLayout.sectionInset            = .zero
    }
    
}

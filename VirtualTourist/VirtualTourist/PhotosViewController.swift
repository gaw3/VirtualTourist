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
        case refreshButton: print("refresh button tapped")
        case trashButton:   print("trash button tapped")
        default: assertionFailure("rcvd tap event for unknown button")
        }
        
    }
    
    var annotation: LocationAnnotation!
    var location:   VTLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        map.addAnnotation(annotation)
        map.setRegion(annotation.region, animated: true)
    }
    
}



// MARK: -
// MARK: - Collection View Data Source

extension PhotosViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IB.ReuseID.TravelogueCollectionViewCell, for: indexPath) as! TravelogueCollectionViewCell
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return location.photos!.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
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

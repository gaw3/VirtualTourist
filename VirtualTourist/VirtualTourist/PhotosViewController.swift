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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}

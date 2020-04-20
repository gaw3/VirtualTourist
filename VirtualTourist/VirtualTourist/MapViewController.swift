//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Gregory White on 4/14/20.
//  Copyright © 2020 Gregory White. All rights reserved.
//

import CoreData
import MapKit
import UIKit

final class MapViewController: UIViewController {

    // MARK: - IB Outlets

    @IBOutlet var      longPress: UILongPressGestureRecognizer!
    @IBOutlet weak var map:       MKMapView!
    
    // MARK: - IB Actions
    
    @IBAction func didRecognize(_ longPress: UILongPressGestureRecognizer) {
        
        if longPress.state == .began {
            
            if inPinDeletionMode {
                presentAlert(.cannotDropPin, message: .whileInDeleteMode)
            } else {
                let coord    = map.convert(longPress.location(in: map), toCoordinateFrom: map)
                let location = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
                let geocoder = CLGeocoder()
                
                geocoder.reverseGeocodeLocation(location, completionHandler: finishReverseGeocoding)
            }
            
        }
        
    }
    
    // MARK: - Variables
    
    var fetchedLocations: FetchedLocationsController!
    
    private var inPinDeletionMode = false
    
    // MARK: - View Events
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: SEL.trashButtonTapped)

        map.addGestureRecognizer(longPress)
        displayAnnotations()
    }
        
}



// MARK: -
// MARK: - Fetched Results Controller Delegate

extension MapViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                      didChange anObject: Any,
                            at indexPath: IndexPath?,
                                for type: NSFetchedResultsChangeType,
                            newIndexPath: IndexPath?) {
        
        if type == .insert {
            let location = anObject as! VTLocation
            map.addAnnotation(location.annotation)
        }
        
    }
    
}



// MARK: -
// MARK: - Map View Delegate

extension MapViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.rightCalloutAccessoryView {
            let photosVC = self.storyboard?.instantiateViewController(withIdentifier: String.StoryboardID.photosVC) as! PhotosViewController
            let annotation = view.annotation as? LocationAnnotation
            
            photosVC.annotation = annotation
            photosVC.location   = coreData.getLocation(withID: annotation!.id)
            
            navigationController?.pushViewController(photosVC, animated: true)
        }
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let anno = (view as? MKMarkerAnnotationView)!.annotation as! LocationAnnotation
        
        if inPinDeletionMode {
            coreData.deleteLocation(withID: anno.id)
            
            mapView.removeAnnotation(anno)
            
            if mapView.annotations.isEmpty {
                didTapDoneButton()
            }
            
        } 
        
    }
     
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let marker = mapView.dequeueReusableAnnotationView(withIdentifier: String.ReuseID.markerAnnoView) as? MKMarkerAnnotationView ??
                     MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: String.ReuseID.markerAnnoView)

        marker.canShowCallout            = true
        marker.animatesWhenAdded         = true
        marker.glyphText                 = "🚀"
        marker.markerTintColor           = .blue
        marker.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        marker.clusteringIdentifier      = String.annoClusteringID

        return marker
    }
    
}



// MARK: -
// MARK: - Private Completion Handlers

private extension MapViewController {
    
    var finishReverseGeocoding: CLGeocodeCompletionHandler {
        
        return { [weak self] (placemarks, error) -> Void in
            
            guard let strongSelf = self else { return }
                        
            guard error == nil else {
                strongSelf.presentAlert(.badGeocode, message: .serverError)
                return
            }
            
            guard placemarks != nil, !placemarks!.isEmpty else {
                strongSelf.presentAlert(.badGeocode, message: .noPlacemarks)
                return
            }
            
            coreData.addLocation(usingPlacemark: placemarks![0] as CLPlacemark)
        }
        
    }
    
}



// MARK: -
// MARK: - Private Helpers

private extension MapViewController {
    
    enum SEL {
        static let trashButtonTapped = #selector(didTapTrashButton)
        static let doneButtonTapped  = #selector(didTapDoneButton)
    }
    
    @objc func didTapDoneButton() {
         navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: SEL.trashButtonTapped)
         inPinDeletionMode = false
    }
    
    @objc func didTapTrashButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: SEL.doneButtonTapped)
        inPinDeletionMode = true
        presentAlert(.tapPins, message: .tapDoneButton)
    }

     
    func displayAnnotations() {
        let fetchRequest: FetchLocationsRequest = VTLocation.fetchRequest()
        
        fetchRequest.sortDescriptors = []
        fetchedLocations = FetchedLocationsController(fetchRequest: fetchRequest,
                                              managedObjectContext: coreData.viewContext,
                                                sectionNameKeyPath: nil,
                                                         cacheName: nil)
        fetchedLocations.delegate = self
        
        do {
            try fetchedLocations.performFetch()
            
            for location in fetchedLocations.fetchedObjects! {
                map.addAnnotation(location.annotation)
            }
            
        } catch let error as NSError {
            print("unable to fetch locations from core data, error = \(error)")
        }
        
    }
    
}

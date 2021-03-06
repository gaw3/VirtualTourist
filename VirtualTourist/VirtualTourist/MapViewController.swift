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
            let coord    = map.convert(longPress.location(in: map), toCoordinateFrom: map)
            let location = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
            let geocoder = CLGeocoder()
                
            geocoder.reverseGeocodeLocation(location, completionHandler: finishReverseGeocoding)
        }
        
    }
    
    // MARK: - Variables
    
    var fetchedLocations: FetchedLocationsController!
    
    private var inPinDeletionMode = false
    private var workflow: GetListOfPhotosWorkflow?
    
    // MARK: - View Events
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: SEL.trashButtonTapped)

        map.addGestureRecognizer(longPress)
        displayAnnotations()
        
        workflow = GetListOfPhotosWorkflow(delegate: self)
    }
        
}



// MARK: -
// MARK: - Core Data Update Delegate

extension MapViewController: CoreDataUpdateDelegate {
    
    func updated(_ location: VTLocation) {
        presentPhotos(forLocation: location)
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
// MARK: - Get List Of Photos Delegate

extension MapViewController: GetListOfPhotosWorkflowDelegate {
    
    func process(_ response: GetListOfPhotosResponse, forLocation location: VTLocation) {
        
        if response.photos.photo.count > 0 {
            coreData.update(location, withResponse: response, delegate: self)
        } else {
            presentAlert(.noPhotos, message: .atThisLocation)
        }
         
    }
    
}



// MARK: -
// MARK: - Map View Delegate

extension MapViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.rightCalloutAccessoryView {
            let annotation = view.annotation as? LocationAnnotation
            let location   = coreData.getLocation(withID: annotation!.id)
        
            mapView.deselectAnnotation(annotation, animated: false)
            
            if location!.numberOfPhotos > 0 {
                presentPhotos(forLocation: location!)
            } else {
                workflow?.getListOfPhotos(forLocation: location!)
            }
            
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
                print("reverse geocoding failed, error = \(error!)")
                strongSelf.presentAlert(.badReverseGeocode, message: .reverseGeocodingError)
                return
            }
            
            guard placemarks != nil, !placemarks!.isEmpty else {
                strongSelf.presentAlert(.badReverseGeocode, message: .noPlacemarks)
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
        longPress.isEnabled = true
        inPinDeletionMode   = false
    }
    
    @objc func didTapTrashButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: SEL.doneButtonTapped)
        longPress.isEnabled = false
        inPinDeletionMode   = true
        presentAlert(.tapMarkers, message: .tapDoneButton)
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
            assertionFailure("unable to fetch locations from core data, error = \(error)")
            presentAlert(.unableToFetchLocations, message: .dbError)
        }
        
    }
    
    func presentPhotos(forLocation location: VTLocation) {
        
        DispatchQueue.main.async(execute: {
            let photosVC = self.storyboard?.instantiateViewController(withIdentifier: String.StoryboardID.photosVC) as! PhotosViewController
            photosVC.location = location
            self.navigationController?.pushViewController(photosVC, animated: true)
        })

    }
    
}

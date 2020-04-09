//
//  TravelLocationsMapViewController.swift
//  VirtualTourist
//
//  Created by Gregory White on 2/24/16.
//  Copyright © 2016 Gregory White. All rights reserved.
//

import CoreData
import CoreLocation
import MapKit
import UIKit

final class TravelLocationsMapViewController: UIViewController {
    
    // MARK: - IB Outlets
    
    @IBOutlet      var longPress: UILongPressGestureRecognizer!
    @IBOutlet weak var mapView:   MKMapView!
    
    // MARK: - IB Actions
    
    @objc func doneButtonWasTapped() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: SEL.TrashButtonTapped)
        inPinDeletionMode = false
    }
    
    @IBAction func handleLongPress(_ gesture: UIGestureRecognizer) {
        
        if gesture.state == .began {
            
            if inPinDeletionMode {
                presentAlert(Alert.Title.CannotDropPin, message: Alert.Message.WhileInDeleteMode)
            } else {
                let coord = mapView.convert(gesture.location(in: mapView), toCoordinateFrom: mapView)
                _ = VirtualTouristTravelLocation(coordinate: coord, context: CoreDataManager.shared.moc)
                CoreDataManager.shared.saveContext()
            }
            
        }
        
    }
    
    @objc func trashButtonWasTapped() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: SEL.DoneButtonTapped)
        inPinDeletionMode = true
        presentAlert(Alert.Title.TapPins, message: Alert.Message.TapDoneButton)
    }
    
    // MARK: - Variables
    
    fileprivate var inPinDeletionMode = false
    
    lazy fileprivate var frc: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: VirtualTouristTravelLocation.Entity.Name)
        fetchRequest.sortDescriptors = []
        
        let frc = NSFetchedResultsController<NSFetchRequestResult>(fetchRequest: fetchRequest, managedObjectContext: CoreDataManager.shared.moc, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        
        return frc
    }()
    
    // MARK: - View Events
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: SEL.TrashButtonTapped)
        mapView.addGestureRecognizer(longPress)
        
        do {
            try frc.performFetch()
            
            for travelLocation in frc.fetchedObjects as! [VirtualTouristTravelLocation] {
                mapView.addAnnotation(travelLocation.pointAnnotation)
            }
            
        } catch let error as NSError {
            self.presentAlert(Alert.Title.BadFetch, message: error.localizedDescription)
        }
        
    }
    
}



// MARK: -
// MARK: - Fetched Results Controller Delegate

extension TravelLocationsMapViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        if type == .insert {
            let travelLocation = anObject as! VirtualTouristTravelLocation
            mapView.addAnnotation(travelLocation.pointAnnotation)
        }
        
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

extension TravelLocationsMapViewController {
    
    func mapView(_ mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        assert(mapView == self.mapView, "Unexpected map view selecting an annotation")
        
        mapView.deselectAnnotation(view.annotation, animated: true)
        let tlpAnnotation = (view as? TravelLocationPinAnnotationView)!.annotation
        
        if inPinDeletionMode {
            mapView.removeAnnotation(tlpAnnotation!)
            
            if mapView.annotations.isEmpty {
                doneButtonWasTapped()
            }
            
            if let travelLocation = getTravelLocation(withCoordinate: tlpAnnotation!.coordinate) {
                deletePhotos(forTravelLocation: travelLocation)
                CoreDataManager.shared.moc.delete(travelLocation)
                CoreDataManager.shared.saveContext()
            }
            
        } else {
            let travelogueVC = self.storyboard?.instantiateViewController(withIdentifier: IB.StoryboardID.TravelogueVC) as! TravelogueViewController
            
            travelogueVC.coordinate = tlpAnnotation!.coordinate
            navigationController?.pushViewController(travelogueVC, animated: true)
        }
        
    }
    
    func mapView(_ mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        assert(mapView == self.mapView, "Unexpected map view requesting view for annotation")
        
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
// MARK: - Private Helpers

private extension TravelLocationsMapViewController {
    
    struct SEL {
        static let TrashButtonTapped = #selector(trashButtonWasTapped)
        static let DoneButtonTapped  = #selector(doneButtonWasTapped)
    }
    
    func deletePhotos(forTravelLocation travelLocation: VirtualTouristTravelLocation)  {
        let photosFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: VirtualTouristPhoto.Entity.Name)
        photosFetchRequest.sortDescriptors = [NSSortDescriptor(key: CoreDataManager.SortKey.Title, ascending: true)]
        photosFetchRequest.predicate = NSPredicate(format: CoreDataManager.Predicate.PhotosByLocation, travelLocation)
        
        do {
            let fetchedPhotos = try CoreDataManager.shared.moc.fetch(photosFetchRequest) as! [VirtualTouristPhoto]
            
            if !fetchedPhotos.isEmpty {
                
                for vtPhoto in fetchedPhotos {
                    CoreDataManager.shared.moc.delete(vtPhoto)
                }
                
                CoreDataManager.shared.saveContext()
            }
            
        } catch let error as NSError {
            self.presentAlert(Alert.Title.BadFetch, message: error.localizedDescription)
        }
        
    }
    
    func getTravelLocation(withCoordinate coordinate: CLLocationCoordinate2D) -> VirtualTouristTravelLocation? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: VirtualTouristTravelLocation.Entity.Name)
        
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate       = NSPredicate(format: CoreDataManager.Predicate.LocationByLatLong, coordinate.latitude, coordinate.longitude)
        
        do {
            let travelLocations = try CoreDataManager.shared.moc.fetch(fetchRequest) as! [VirtualTouristTravelLocation]
            
            if !travelLocations.isEmpty { return travelLocations[0] }
            else                        { return nil }
            
        } catch let error as NSError {
            self.presentAlert(Alert.Title.BadFetch, message: error.localizedDescription)
        }
        
        return nil
    }
    
}

//
//  CoreDataStack.swift
//  VirtualTourist
//
//  Created by Gregory White on 4/14/20.
//  Copyright © 2020 Gregory White. All rights reserved.
//

import CoreData
import CoreLocation

typealias FetchedLocationsController = NSFetchedResultsController<VTLocation>
typealias FetchLocationsRequest      = NSFetchRequest<VTLocation>

final class CoreDataStack {
    
    // MARK: - Variables

    static let shared = CoreDataStack()
    
    static let locationEntityName = "VTLocation"
    static let photoEntityName    = "VTPhoto"
    static let modelName          = "VT"

    lazy var newBackgroundContext: NSManagedObjectContext = {
        let context = self.persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        return context
    }()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: CoreDataStack.modelName)
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            
            if let error = error as NSError? {
                print("error loading persistent stores, Error = \(error)")
                abort()
            }
            
        })
        
        container.viewContext.stalenessInterval = 0
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        return container
    }()
    
    lazy var viewContext: NSManagedObjectContext = {
        return self.persistentContainer.viewContext
    }()
    
}



// MARK: -
// MARK: - API

extension CoreDataStack {

    func addLocation(usingPlacemark placemark: CLPlacemark) {
        let newBackgroundContext = self.newBackgroundContext
        
        newBackgroundContext.perform {
            
            do {
                _ = VTLocation(usingPlacemark: placemark, insertInto: newBackgroundContext)
                try newBackgroundContext.save()
            } catch let error {
                print("error adding location, error = \(error)")
                assertionFailure()
            }
            
        }
        
    }
    
    func addPhotos(toLocation location: VTLocation, images: [Photo]) {
        let newBackgroundContext = self.newBackgroundContext
        
        newBackgroundContext.perform {
            
            for image in images {
                let vtPhoto = VTPhoto(usingPhoto: image, insertInto: location.managedObjectContext!)
                vtPhoto.location = location
                location.photos?.adding(vtPhoto)
            }
            
            do {
                try newBackgroundContext.save()
            } catch let error {
                print("error adding location, error = \(error)")
                assertionFailure()
            }
            
        }

    }
    
    func deleteLocation(withID id: String) {
        let fetchRequest: FetchLocationsRequest = VTLocation.fetchRequest()
        
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate       = NSPredicate(format: "id == %@", id)
        
        do {
            let locations = try viewContext.fetch(fetchRequest)
            
            if !locations.isEmpty {
                viewContext.delete(locations[0])
                try viewContext.save()
            }
            
        } catch let error as NSError {
            print("error deleting location with id = \(id), error = \(error)")
            assertionFailure()
        }
        
    }
    
    func getLocation(withID id: String) -> VTLocation? {
        let fetchRequest: FetchLocationsRequest = VTLocation.fetchRequest()
        
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate       = NSPredicate(format: "id == %@", id)
        
        do {
            let locations = try viewContext.fetch(fetchRequest)
            
            if !locations.isEmpty {
                return locations[0]
            } else {
                print("did not find location with ID = \(id)")
                return nil
            }
            
        } catch let error as NSError {
            print("error getting location with id = \(id), error = \(error)")
            assertionFailure()
            return nil
        }
        
    }
    
    func save() {
        
        if viewContext.hasChanges {
            
            do {
                try viewContext.save()
            } catch let error as NSError {
                print("unable to save view context, Error = \(error)")
                assertionFailure()
            }
            
        }
        
    }
    
}

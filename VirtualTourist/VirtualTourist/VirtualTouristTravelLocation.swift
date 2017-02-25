//
//  VirtualTouristTravelLocation.swift
//  VirtualTourist
//
//  Created by Gregory White on 3/12/16.
//  Copyright © 2016 Gregory White. All rights reserved.
//

import CoreData
import CoreLocation
import Foundation
import MapKit

final class VirtualTouristTravelLocation: NSManagedObject {
    
    // MARK: - @NSManaged
    
    @NSManaged var annotationID:       String
    @NSManaged var annotationTitle:    String
    @NSManaged var annotationSubtitle: String
    @NSManaged var latitude:           NSNumber
    @NSManaged var longitude:          NSNumber
    @NSManaged var page:               NSNumber
    @NSManaged var perPage:            NSNumber
    @NSManaged var photos:             [VirtualTouristPhoto]
    
    // MARK: - Constants
    
    struct Consts {
        static let EntityName = "VirtualTouristTravelLocation"
    }
    
    // MARK: - API
    
    var pointAnnotation: MKPointAnnotation {
        let anno = MKPointAnnotation()
        
        anno.coordinate.latitude  = latitude  as CLLocationDegrees
        anno.coordinate.longitude = longitude as CLLocationDegrees
        
        return anno
    }
    
    var searchQuery: String {
        let lat     = latitude  as Double
        let long    = longitude as Double
        let newPage = (page as Int) + 1
        let query   = "api_key=850364777cd6c0359001c9aa67b5b1b4&content_type=1&extras=url_m&format=json&lat=\(lat)&lon=\(long)&method=flickr.photos.search&nojsoncallback=1&page=\(newPage)&per_page=21&safe_search=1"
        
        return query
    }
    
    // MARK: - API
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(coordinate: CLLocationCoordinate2D, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: Consts.EntityName, in: context)!
        super.init(entity: entity, insertInto: context)
        
        latitude  = NSNumber(value: coordinate.latitude)
        longitude = NSNumber(value: coordinate.longitude)
    }
    
}

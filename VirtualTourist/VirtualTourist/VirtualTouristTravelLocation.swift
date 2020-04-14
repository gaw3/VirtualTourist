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
    
    // MARK: - Constants
    
    struct Entity {
        static let Name = "VirtualTouristTravelLocation"
    }
    
    // MARK: - Variables
    
    var pointAnnotation: MKPointAnnotation {
        let anno = MKPointAnnotation()
        
        anno.coordinate.latitude  = CLLocationDegrees(truncating: latitude)
        anno.coordinate.longitude = CLLocationDegrees(truncating: longitude)
        anno.title                = annotationTitle
        anno.subtitle             = annotationSubtitle
        
        return anno
    }
    
    var searchQuery: String {
        let lat     = Double(truncating: latitude)
        let long    = Double(truncating: longitude)
        let newPage = Int(truncating: page) + 1
        let query   = "api_key=850364777cd6c0359001c9aa67b5b1b4&content_type=1&extras=url_m&format=json&lat=\(lat)&lon=\(long)&method=flickr.photos.search&nojsoncallback=1&page=\(newPage)&per_page=21&safe_search=1"
        
        return query
    }
    
    // MARK: - Init
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
}



// MARK: -
// MARK: - API

extension VirtualTouristTravelLocation {

    convenience init(placemark: CLPlacemark, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: Entity.Name, in: context)!
        self.init(entity: entity, insertInto: context)
        
        latitude  = placemark.location!.coordinate.latitude  as NSNumber
        longitude = placemark.location!.coordinate.longitude as NSNumber
        
        if let locality = placemark.locality {
            annotationTitle = "\(locality), "
        }
        
        if let adminArea = placemark.administrativeArea {
            annotationTitle.append("\(adminArea), ")
        }
        
        if let postalCode = placemark.postalCode {
            annotationTitle.append("\(postalCode)  ")
        }
        
        if let country = placemark.country {
            annotationTitle.append(country)
        }
        
        annotationSubtitle = "\(latitude), \(longitude)"
    }
    
}

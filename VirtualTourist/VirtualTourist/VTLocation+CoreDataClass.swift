//
//  VTLocation+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Gregory White on 4/14/20.
//  Copyright © 2020 Gregory White. All rights reserved.
//
//

import Foundation
import CoreData
import CoreLocation
import MapKit

@objc(VTLocation)
public final class VTLocation: NSManagedObject {
    
    // MARK: - Variables
    
    var annotation: LocationAnnotation {
        return LocationAnnotation(lat: lat, long: long, title: title!, subtitle: subtitle!, id: id!)
    }
    
    var numberOfPhotos: Int   { return photos!.count }
    var nextPage:       Int64 { return page <= pages ? page + 1 : 1 }

    // MARK: - Initializers
    
    convenience init(usingPlacemark placemark: CLPlacemark, insertInto context: NSManagedObjectContext) {
        
        if let entity = NSEntityDescription.entity(forEntityName: CoreDataStack.locationEntityName, in: context) {
            self.init(entity: entity, insertInto: context)
            
            id   = String(format:"%f", Date().timeIntervalSinceReferenceDate)
            lat  = placemark.location!.coordinate.latitude
            long = placemark.location!.coordinate.longitude
            
            var titleParts = ""
            
            if let locality = placemark.locality {
                titleParts = "\(locality), "
            }
            
            if let adminArea = placemark.administrativeArea {
                titleParts.append("\(adminArea), ")
            }
            
            if let postalCode = placemark.postalCode {
                titleParts.append("\(postalCode)  ")
            }
            
            if let country = placemark.country {
                if country == "United States" {
                    titleParts.append("USA")
                } else {
                    titleParts.append(country)
                }
            }
            
            title    = titleParts
            subtitle = "\(lat), \(long)"
        } else {
            print("unable to construct a VTLocation entity")
            abort()
        }
        
    }
        
}

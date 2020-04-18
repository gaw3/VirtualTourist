//
//  LocationAnnotation.swift
//  VirtualTourist
//
//  Created by Gregory White on 4/17/20.
//  Copyright © 2020 Gregory White. All rights reserved.
//

import MapKit

final class LocationAnnotation: MKPointAnnotation {
    
    // MARK: - Variables

    let id: String
    
    // MARK: - Initializers

    init(lat: CLLocationDegrees, long: CLLocationDegrees, title: String, subtitle: String, id: String) {
        self.id = id
        
        super.init()

        coordinate    = CLLocationCoordinate2DMake(lat, long)
        self.title    = title
        self.subtitle = subtitle
    }

}

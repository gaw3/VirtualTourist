//
//  VirtualTouristTravelLocation+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Gregory White on 2/25/17.
//  Copyright © 2017 Gregory White. All rights reserved.
//

import Foundation

extension VirtualTouristTravelLocation {
    
    @NSManaged var annotationID:       String
    @NSManaged var annotationTitle:    String
    @NSManaged var annotationSubtitle: String
    @NSManaged var latitude:           NSNumber
    @NSManaged var longitude:          NSNumber
    @NSManaged var page:               NSNumber
    @NSManaged var perPage:            NSNumber
    @NSManaged var photos:             [VirtualTouristPhoto]

}

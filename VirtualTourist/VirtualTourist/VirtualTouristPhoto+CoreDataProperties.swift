//
//  VirtualTouristPhoto+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Gregory White on 2/25/17.
//  Copyright © 2017 Gregory White. All rights reserved.
//

import Foundation

extension VirtualTouristPhoto {
    
    @NSManaged var imageURLString: String
    @NSManaged var title:          String
    @NSManaged var location:       VirtualTouristTravelLocation?
    
}

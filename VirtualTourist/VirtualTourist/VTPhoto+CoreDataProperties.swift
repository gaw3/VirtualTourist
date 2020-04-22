//
//  VTPhoto+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Gregory White on 4/14/20.
//  Copyright © 2020 Gregory White. All rights reserved.
//
//

import Foundation
import CoreData

extension VTPhoto {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<VTPhoto> {
        return NSFetchRequest<VTPhoto>(entityName: CoreDataStack.photoEntityName)
    }

    @NSManaged public var imageData: Data?
    @NSManaged public var url:       String?
    @NSManaged public var title:     String?
    @NSManaged public var id:        String?
    @NSManaged public var location:  VTLocation?
}

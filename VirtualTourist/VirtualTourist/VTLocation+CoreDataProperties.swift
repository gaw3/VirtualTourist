//
//  VTLocation+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Gregory White on 4/14/20.
//  Copyright © 2020 Gregory White. All rights reserved.
//
//

import Foundation
import CoreData

extension VTLocation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<VTLocation> {
        return NSFetchRequest<VTLocation>(entityName: CoreDataStack.locationEntityName)
    }

    @NSManaged public var title: String?
    @NSManaged public var subtitle: String?
    @NSManaged public var lat: Double
    @NSManaged public var long: Double
    @NSManaged public var page: Int64
    @NSManaged public var perpage: Int64
    @NSManaged public var id: String?
    @NSManaged public var photos: NSSet?

}

// MARK: Generated accessors for photos

extension VTLocation {

    @objc(addPhotosObject:)
    @NSManaged public func addToPhotos(_ value: VTPhoto)

    @objc(removePhotosObject:)
    @NSManaged public func removeFromPhotos(_ value: VTPhoto)

    @objc(addPhotos:)
    @NSManaged public func addToPhotos(_ values: NSSet)

    @objc(removePhotos:)
    @NSManaged public func removeFromPhotos(_ values: NSSet)

}

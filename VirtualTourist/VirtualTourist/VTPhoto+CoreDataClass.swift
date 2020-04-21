//
//  VTPhoto+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Gregory White on 4/14/20.
//  Copyright © 2020 Gregory White. All rights reserved.
//
//

import Foundation
import CoreData

@objc(VTPhoto)
public final class VTPhoto: NSManagedObject {

    convenience init(usingPhoto photo: Photo, insertInto context: NSManagedObjectContext) {

        if let entity = NSEntityDescription.entity(forEntityName: CoreDataStack.photoEntityName, in: context) {
            self.init(entity: entity, insertInto: context)
            
            id    = photo.id
            url   = photo.url
            title = photo.title
            
        } else {
            print("unable to construct a VTPhoto entity")
            abort()
        }

    }
    
}

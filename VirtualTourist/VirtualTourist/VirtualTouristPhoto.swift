//
//  VirtualTouristPhoto.swift
//  VirtualTourist
//
//  Created by Gregory White on 3/12/16.
//  Copyright © 2016 Gregory White. All rights reserved.
//

import CoreData
import Foundation

final class VirtualTouristPhoto: NSManagedObject {
    
    // MARK: - Constants
    
    struct Entity {
        static let Name = "VirtualTouristPhoto"
    }
    
    // MARK: - Variables
    
    var fileName: String {
        return imageURLString.components(separatedBy: "/").last!
    }
    
    // MARK: - Init
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
}



// MARK: -
// MARK: - API

extension VirtualTouristPhoto {
    
    convenience init(responseData: FlickrPhotoResponseData, context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entity(forEntityName: Entity.Name, in: context)!
        self.init(entity: entity, insertInto: context)
        
        title          = responseData.title
        imageURLString = responseData.url_m
    }
    
    override func prepareForDeletion() {
        PhotoCache.shared.removeImage(withCacheID: fileName)
    }
    
}

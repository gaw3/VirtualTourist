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
    
    // MARK: - @NSManaged
    
    @NSManaged var imageURLString: String
    @NSManaged var title:          String
    @NSManaged var location:       VirtualTouristTravelLocation?
    
    // MARK: - Constants
    
    struct Consts {
        static let EntityName = "VirtualTouristPhoto"
    }
    
    var fileName: String {
        return imageURLString.components(separatedBy: "/").last!
    }
    
    // MARK: - API
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(responseData: FlickrPhotoResponseData, context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entity(forEntityName: Consts.EntityName, in: context)!
        super.init(entity: entity, insertInto: context)
        
        title          = responseData.title
        imageURLString = responseData.url_m
    }
    
    override func prepareForDeletion() {
        PhotoCache.sharedCache.removeImageWithCacheID(fileName)
    }
    
}

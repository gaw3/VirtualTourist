//
//  VirtualTouristPhoto.swift
//  VirtualTourist
//
//  Created by Gregory White on 3/12/16.
//  Copyright © 2016 Gregory White. All rights reserved.
//

import CoreData
import Foundation

final internal class VirtualTouristPhoto: NSManagedObject {
	
	// MARK: - @NSManaged

	@NSManaged var title:          String
	@NSManaged var imageURLString: String

	// MARK: - Internal Constants

	internal struct Consts {
		static let EntityName = "VirtualTouristPhoto"
	}

	// MARK: - API

	override internal init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
		super.init(entity: entity, insertIntoManagedObjectContext: context)
	}

	internal init(responseData: FlickrPhotoResponseData, context: NSManagedObjectContext) {
		let entity =  NSEntityDescription.entityForName(Consts.EntityName, inManagedObjectContext: context)!
		super.init(entity: entity, insertIntoManagedObjectContext: context)

		title          = responseData.title
		imageURLString = responseData.url_m
	}

}

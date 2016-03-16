//
//  VirtualTouristTravelLocation.swift
//  VirtualTourist
//
//  Created by Gregory White on 3/12/16.
//  Copyright © 2016 Gregory White. All rights reserved.
//

import CoreData
import Foundation
import MapKit

final internal class VirtualTouristTravelLocation: NSManagedObject {

	// MARK: - @NSManaged

	@NSManaged var annotationID:       String
	@NSManaged var annotationTitle:    String
	@NSManaged var annotationSubtitle: String
	@NSManaged var latitude:           NSNumber
	@NSManaged var longitude:          NSNumber
	@NSManaged var page:               NSNumber
	@NSManaged var perPage:            NSNumber

	// MARK: - Internal Constants

	internal struct Consts {
		static let EntityName = "VirtualTouristTravelLocation"
	}

	// MARK: - API

	internal var pointAnnotation: MKPointAnnotation {
		let anno = MKPointAnnotation()

		anno.coordinate.latitude  = latitude  as CLLocationDegrees
      anno.coordinate.longitude = longitude as CLLocationDegrees

		return anno
	}

	// MARK: - API

	override internal init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
		super.init(entity: entity, insertIntoManagedObjectContext: context)
	}

	internal init(coordinate: CLLocationCoordinate2D, context: NSManagedObjectContext) {
		let entity =  NSEntityDescription.entityForName(Consts.EntityName, inManagedObjectContext: context)!
		super.init(entity: entity, insertIntoManagedObjectContext: context)

		latitude  = coordinate.latitude
		longitude = coordinate.longitude
	}

	internal init(responseData: FlickrPhotosResponseData, annotation: MKPointAnnotation, context: NSManagedObjectContext) {
		let entity =  NSEntityDescription.entityForName(Consts.EntityName, inManagedObjectContext: context)!
		super.init(entity: entity, insertIntoManagedObjectContext: context)

		page               = responseData.page
		perPage            = responseData.perpage
		
		annotationTitle    = annotation.title!
		annotationSubtitle = annotation.subtitle!
		latitude           = annotation.coordinate.latitude
		longitude          = annotation.coordinate.longitude
	}

}

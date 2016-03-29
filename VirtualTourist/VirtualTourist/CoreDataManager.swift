//
//  CoreDataManager.swift
//  VirtualTourist
//
//  Created by Gregory White on 3/12/16.
//  Copyright © 2016 Gregory White. All rights reserved.
//

import CoreData
import Foundation

private let _sharedManager = CoreDataManager()

final internal class CoreDataManager: NSObject {

	class internal var sharedManager: CoreDataManager {
		return _sharedManager
	}

	// MARK: - Internal Constants

	internal struct SortKey {
		static let Title = "title"
	}

	internal struct Predicate {
		static let LocationByLatLong = "latitude == %lf and longitude == %lf"
		static let PhotosByLocation  = "location == %@"
	}
	
	// MARK: - Private Constants

	private struct Consts {
		static let DBFilename     = "VirtualTourist.sqlite"
		static let ModelName      = "VirtualTourist"
		static let ModelExtension = "momd"
	}
	
	// MARK: - Internal Computed Variables

	lazy internal var appDocsDir: NSURL = {
		return NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
	}()

	lazy internal var moc: NSManagedObjectContext = {
		let moc = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
		moc.persistentStoreCoordinator = self.psc
		return moc
	}()

	lazy internal var mom: NSManagedObjectModel = {
		let modelURL = NSBundle.mainBundle().URLForResource(Consts.ModelName, withExtension: Consts.ModelExtension)!
		return NSManagedObjectModel(contentsOfURL: modelURL)!
	}()

	lazy internal var psc: NSPersistentStoreCoordinator? = {
		let psc    = NSPersistentStoreCoordinator(managedObjectModel: self.mom)
		let pscURL = self.appDocsDir.URLByAppendingPathComponent(Consts.DBFilename)

		do {
			try psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: pscURL, options: nil)
		} catch let error as NSError {
			print("\(error)")
			return nil
		}

		return psc
	}()

	// MARK: - API

	internal func saveContext() {

		if moc.hasChanges {

			do {
				try moc.save()
			} catch let error as NSError {
				print("\(error)")
			}

		}

	}

}

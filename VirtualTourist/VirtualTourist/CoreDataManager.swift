//
//  CoreDataManager.swift
//  VirtualTourist
//
//  Created by Gregory White on 3/12/16.
//  Copyright © 2016 Gregory White. All rights reserved.
//

import CoreData
import Foundation

private let _shared = CoreDataManager()

final class CoreDataManager: NSObject {
    
    class var shared: CoreDataManager {
        return _shared
    }
    
    // MARK: - Constants
    
    struct SortKey {
        static let Title = "title"
    }
    
    struct Predicate {
        static let LocationByLatLong = "latitude == %lf and longitude == %lf"
        static let PhotosByLocation  = "location == %@"
    }
    
    // MARK: - Private Constants
    
    fileprivate struct Consts {
        static let DBFilename     = "VirtualTourist.sqlite"
        static let ModelName      = "VirtualTourist"
        static let ModelExtension = "momd"
    }
    
    // MARK: - Variables
    
    lazy var appDocsDir: URL = {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }()
    
    lazy var moc: NSManagedObjectContext = {
        let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        moc.persistentStoreCoordinator = self.psc
        return moc
    }()
    
    lazy var mom: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: Consts.ModelName, withExtension: Consts.ModelExtension)!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var psc: NSPersistentStoreCoordinator? = {
        let psc    = NSPersistentStoreCoordinator(managedObjectModel: self.mom)
        let pscURL = self.appDocsDir.appendingPathComponent(Consts.DBFilename)
        
        do {
            try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: pscURL, options: nil)
        } catch let error as NSError {
            print("\(error)")
            return nil
        }
        
        return psc
    }()
    
    // MARK: - API
    
    func saveContext() {
        
        if moc.hasChanges {
            
            do {
                try moc.save()
            } catch let error as NSError {
                print("\(error)")
            }
            
        }
        
    }
    
}

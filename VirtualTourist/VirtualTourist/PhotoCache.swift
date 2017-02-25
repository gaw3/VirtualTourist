//
//  PhotoCache.swift
//  VirtualTourist
//
//  Created by Gregory White on 3/23/16.
//  Copyright © 2016 Gregory White. All rights reserved.
//

import UIKit

private let _shared = PhotoCache()

final class PhotoCache {
    
    class var shared: PhotoCache {
        return _shared
    }
    
    // MARK: -Variables
    
    fileprivate var cache = NSCache<AnyObject, AnyObject>()
}

// MARK: -
// MARK: - API

extension PhotoCache {

    func image(withCacheID id: String) -> UIImage? {
        
        // First try the memory cache
        if let image = cache.object(forKey: id as AnyObject) as? UIImage {
            return image
        }
        
        // Next try the hard drive
        if let data = try? Data(contentsOf: URL(fileURLWithPath: path(forIdentifier: id))) {
            return UIImage(data: data)
        }
        
        return nil
    }
    
    func removeImage(withCacheID id: String) {
        self.cache.removeObject(forKey: id as AnyObject)
        
        if FileManager.default.fileExists(atPath: path(forIdentifier: id)) {
            
            do {
                try FileManager.default.removeItem(atPath: path(forIdentifier: id))
            } catch let error as NSError {
                print("\(error)")
            }
            
        }
        
    }
    
    func storeImage(_ image: UIImage, withCacheID id: String) {
        cache.setObject(image, forKey: id as AnyObject)
        
        let imageData = UIImagePNGRepresentation(image)!
        
        if !((try? imageData.write(to: URL(fileURLWithPath: path(forIdentifier: id)), options: [.atomic])) != nil) {
            print("FAILED adding image to documents = \(path)")
        }
        
    }
    
}



// MARK: -
// MARK: - Private Helpers

private extension PhotoCache {
    
    func path(forIdentifier identifier: String) -> String {
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fullURL               = documentsDirectoryURL.appendingPathComponent(identifier)
        
        return fullURL.path
    }
    
}

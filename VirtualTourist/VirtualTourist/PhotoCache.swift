//
//  PhotoCache.swift
//  VirtualTourist
//
//  Created by Gregory White on 3/23/16.
//  Copyright © 2016 Gregory White. All rights reserved.
//

import Foundation
import UIKit

private let _sharedCache = PhotoCache()

final internal class PhotoCache {

	class internal var sharedCache: PhotoCache {
		return _sharedCache
	}

	// MARK: - Private Stored Variables

	private var memoryCache = NSCache()

	// MARK: - Private Computed Variables

	private var fileMgr: NSFileManager {
		return NSFileManager.defaultManager()
	}

	// MARK: - API

	internal func imageWithCacheID(id: String) -> UIImage? {

		// First try the memory cache
		if let image = memoryCache.objectForKey(id) as? UIImage {
			return image
		}

		// Next try the hard drive
		if let data = NSData(contentsOfFile: pathForIdentifier(id)) {
			return UIImage(data: data)
		}

		return nil
	}

	internal func removeImageWithCacheID(id: String) {
		memoryCache.removeObjectForKey(id)

		let path = pathForIdentifier(id)

		if fileMgr.fileExistsAtPath(path) {

			do {
				try fileMgr.removeItemAtPath(path)
			} catch let error as NSError {
				print("\(error)")
			}
			
		}

	}

	internal func storeImage(image: UIImage, withCacheID id: String) {
		memoryCache.setObject(image, forKey: id)

		let imageData = UIImagePNGRepresentation(image)!
		let path      = pathForIdentifier(id)

		if !imageData.writeToFile(path, atomically: true) {
			print("FAILED adding image to documents = \(path)")
		}

	}

	// MARK: - Private

	private func pathForIdentifier(identifier: String) -> String {
		let documentsDirectoryURL = fileMgr.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
		let fullURL               = documentsDirectoryURL.URLByAppendingPathComponent(identifier)

		return fullURL.path!
	}
	
}
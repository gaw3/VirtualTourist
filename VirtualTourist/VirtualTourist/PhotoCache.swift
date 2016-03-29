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

final internal class PhotoCache : NSObject {

	class internal var sharedCache: PhotoCache {
		return _sharedCache
	}

	// MARK: - Private Stored Variables

	private var inMemoryCache = NSCache()

	// MARK: - Private Computed Variables

	private var fileMgr: NSFileManager {
		return NSFileManager.defaultManager()
	}

	// MARK: - API

	internal func imageWithIdentifier(identifier: String?) -> UIImage? {

		// If the identifier is nil, or empty, return nil
		if identifier == nil || identifier! == "" {
			return nil
		}

		let path = pathForIdentifier(identifier!)

		// First try the memory cache
		if let image = inMemoryCache.objectForKey(path) as? UIImage {
			return image
		}

		// Next Try the hard drive
		if let data = NSData(contentsOfFile: path) {
			return UIImage(data: data)
		}

		return nil
	}

	internal func storeImage(image: UIImage?, withIdentifier identifier: String) {
		let path = pathForIdentifier(identifier)

		// If the image is nil, remove images from the cache
		if image == nil {
			inMemoryCache.removeObjectForKey(path)

			do {
				try fileMgr.removeItemAtPath(path)
			} catch _ {}

			return
		}

		// Otherwise, keep the image in memory
		inMemoryCache.setObject(image!, forKey: path)

		// And in documents directory
		let data = UIImagePNGRepresentation(image!)!
		data.writeToFile(path, atomically: true)
	}

	// MARK: - Private

	private func pathForIdentifier(identifier: String) -> String {
		let documentsDirectoryURL: NSURL = fileMgr.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
		let fullURL = documentsDirectoryURL.URLByAppendingPathComponent(identifier)

		return fullURL.path!
	}
	
}
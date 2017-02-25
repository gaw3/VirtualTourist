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

final class PhotoCache {

	class var sharedCache: PhotoCache {
		return _sharedCache
	}

	// MARK: - Private Stored Variables

	fileprivate var memoryCache = NSCache<AnyObject, AnyObject>()

	// MARK: - Private Computed Variables

	fileprivate var fileMgr: FileManager {
		return FileManager.default
	}

	// MARK: - API

	func imageWithCacheID(_ id: String) -> UIImage? {

		// First try the memory cache
		if let image = memoryCache.object(forKey: id as AnyObject) as? UIImage {
			return image
		}

		// Next try the hard drive
		if let data = try? Data(contentsOf: URL(fileURLWithPath: pathForIdentifier(id))) {
			return UIImage(data: data)
		}

		return nil
	}

	func removeImageWithCacheID(_ id: String) {
		memoryCache.removeObject(forKey: id as AnyObject)

		let path = pathForIdentifier(id)

		if fileMgr.fileExists(atPath: path) {

			do {
				try fileMgr.removeItem(atPath: path)
			} catch let error as NSError {
				print("\(error)")
			}
			
		}

	}

	func storeImage(_ image: UIImage, withCacheID id: String) {
		memoryCache.setObject(image, forKey: id as AnyObject)

		let imageData = UIImagePNGRepresentation(image)!
		let path      = pathForIdentifier(id)

		if !((try? imageData.write(to: URL(fileURLWithPath: path), options: [.atomic])) != nil) {
			print("FAILED adding image to documents = \(path)")
		}

	}

	// MARK: - Private

	fileprivate func pathForIdentifier(_ identifier: String) -> String {
		let documentsDirectoryURL = fileMgr.urls(for: .documentDirectory, in: .userDomainMask).first!
		let fullURL               = documentsDirectoryURL.appendingPathComponent(identifier)

		return fullURL.path
	}
	
}

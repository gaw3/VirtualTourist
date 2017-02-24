//
//  FlickrPhotosResponseData.swift
//  VirtualTourist
//
//  Created by Gregory White on 3/12/16.
//  Copyright © 2016 Gregory White. All rights reserved.
//

import Foundation

internal struct FlickrPhotosResponseData {

	// MARK: - Private Stored Variables

	fileprivate var _photos: JSONDictionary
	fileprivate var _stat:   String

	// MARK: - Internal Computed Variables

	internal var isStatusOK: Bool {
		return _stat == FlickrAPIClient.API.StatusValueOK
	}

	internal var page: Int {
		return _photos[FlickrAPIClient.API.PageKey] as! Int
	}

	internal var perpage: Int {
		return _photos[FlickrAPIClient.API.PerPageKey] as! Int
	}

	internal var photoArray: [FlickrPhotoResponseData] {
		let photoJSONDict = _photos[FlickrAPIClient.API.PhotoKey] as! [JSONDictionary]
		var flickrPhotos  = [FlickrPhotoResponseData]()

		for json in photoJSONDict {
         flickrPhotos.append(FlickrPhotoResponseData(dictionary: json))
		}

		return flickrPhotos
	}

	// MARK: - API

	internal init(responseData: JSONDictionary) {
		 _stat = responseData[FlickrAPIClient.API.StatusKey] as! String

		if _stat == FlickrAPIClient.API.StatusValueOK {
			_photos = responseData[FlickrAPIClient.API.PhotosKey] as! JSONDictionary
		} else {
			_photos = [:]
		}

	}

}

//
//  FlickrPhotosResponseData.swift
//  VirtualTourist
//
//  Created by Gregory White on 3/12/16.
//  Copyright © 2016 Gregory White. All rights reserved.
//

import Foundation

struct FlickrPhotosResponseData {

	// MARK: - Private Stored Variables

	private var _photos: JSONDictionary
	private var _stat:   String

	// MARK: - Internal Computed Variables

	internal var isStatusOK: Bool {
		return _stat == "ok"
	}

	internal var page: Int {
		return _photos["page"] as! Int
	}

	internal var perpage: Int {
		return _photos["perpage"] as! Int
	}

	internal var photoArray: [FlickrPhotoResponseData] {
		let photoJSONDict = _photos["photo"] as! [JSONDictionary]
		var flickrPhotos  = [FlickrPhotoResponseData]()

		for json in photoJSONDict {
         flickrPhotos.append(FlickrPhotoResponseData(dictionary: json))
		}

		return flickrPhotos
	}

	// MARK: - API

	internal init(responseData: JSONDictionary) {
		 _stat = responseData["stat"] as!  String

		if _stat == "ok" {
			_photos = responseData["photos"] as! JSONDictionary
		} else {
			_photos = [:]
		}

	}

}

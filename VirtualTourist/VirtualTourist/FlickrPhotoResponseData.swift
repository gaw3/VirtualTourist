//
//  FlickrPhotoResponseData.swift
//  VirtualTourist
//
//  Created by Gregory White on 3/12/16.
//  Copyright © 2016 Gregory White. All rights reserved.
//

import Foundation

internal struct FlickrPhotoResponseData {

	// MARK: - Private Stored Variables

	private var _photo: JSONDictionary

	// MARK: - Internal Computed Variables

	internal var title: String {
		return _photo[FlickrAPIClient.API.TitleKey] as! String
	}

	internal var url_m: String {
		return _photo[FlickrAPIClient.API.URLKey] as! String
	}

	// MARK: - API

	internal init(dictionary: JSONDictionary) {
      _photo = dictionary
	}

}
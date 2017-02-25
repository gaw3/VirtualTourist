//
//  FlickrPhotoResponseData.swift
//  VirtualTourist
//
//  Created by Gregory White on 3/12/16.
//  Copyright © 2016 Gregory White. All rights reserved.
//

import Foundation

struct FlickrPhotoResponseData {

	// MARK: - Variables

	fileprivate var _photo: JSONDictionary

	// MARK: - Variables

	var title: String {
		return _photo[FlickrAPIClient.API.TitleKey] as! String
	}

	var url_m: String {
		return _photo[FlickrAPIClient.API.URLKey] as! String
	}

	// MARK: - API

	init(dictionary: JSONDictionary) {
      _photo = dictionary
	}

}

//
//  FlickrPhotoResponseData.swift
//  VirtualTourist
//
//  Created by Gregory White on 3/12/16.
//  Copyright © 2016 Gregory White. All rights reserved.
//

import Foundation

struct FlickrPhotoResponseData {

	private var _photo: JSONDictionary

	internal var title: String {
		return _photo["title"] as! String
	}

	internal var url_m: String {
		return _photo["url_m"] as! String
	}

	internal init(dictionary: JSONDictionary) {
      _photo = dictionary
	}

}
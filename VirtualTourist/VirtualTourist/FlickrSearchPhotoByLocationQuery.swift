//
//  FlickrSearchPhotosByLocationQuery.swift
//  VirtualTourist
//
//  Created by Gregory White on 3/12/16.
//  Copyright © 2016 Gregory White. All rights reserved.
//

import CoreLocation
import Foundation

struct FlickrSearchPhotosByLocationQuery {

   // MARK: - Private Stored Variables

	private let loc: CLLocationCoordinate2D

	// MARK: - Internal Computed Variables

	internal var query: String {
		return "api_key=850364777cd6c0359001c9aa67b5b1b4&content_type=1&extras=url_m&format=json&lat=\(loc.latitude)&lon=\(loc.longitude)&method=flickr.photos.search&nojsoncallback=1&page=4&per_page=15&safe_search=1"
	}

	// MARK: - API

	init(location: CLLocationCoordinate2D) {
      loc = location
	}

}



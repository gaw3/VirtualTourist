//
//  TravelLocationAnnotation.swift
//  VirtualTourist
//
//  Created by Gregory White on 2/27/16.
//  Copyright © 2016 Gregory White. All rights reserved.
//

import AddressBookUI
import MapKit

final internal class TravelLocationAnnotation: MKPointAnnotation {

	private var _placemark: CLPlacemark? = nil

	internal var placemark: CLPlacemark {
		get { return _placemark! }

		set(newPlacemark) {
			_placemark = newPlacemark

			let formattedAddress = ABCreateStringWithAddressDictionary(newPlacemark.addressDictionary!, false)
			title = formattedAddress.stringByReplacingOccurrencesOfString("\n", withString: ", ")
			subtitle = "\(_placemark!.location!.coordinate.latitude), \(_placemark!.location!.coordinate.longitude)"
		}

	}

}

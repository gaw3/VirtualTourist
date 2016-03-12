//
//  CLPlacemarkExtensions.swift
//  VirtualTourist
//
//  Created by Gregory White on 3/12/16.
//  Copyright © 2016 Gregory White. All rights reserved.
//

import AddressBookUI
import CoreLocation

extension CLPlacemark {

	var formattedAddress: String {
		let formattedAddress = ABCreateStringWithAddressDictionary(self.addressDictionary!, false)
		return formattedAddress.stringByReplacingOccurrencesOfString("\n", withString: ", ")
	}

}


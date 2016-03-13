//
//  TravelogueViewController.swift
//  VirtualTourist
//
//  Created by Gregory White on 2/26/16.
//  Copyright © 2016 Gregory White. All rights reserved.
//

import MapKit
import UIKit

final internal class TravelogueViewController: UIViewController {

	// MARK: - Internal Constants

	internal struct UI {
		static let StoryboardID = "TravelogueVC"
	}

	// MARK: - Internal Stored Variables

	internal var tlPinAnnoView: TravelLocationPinAnnotationView? = nil

	// MARK: - IB Outlets

	@IBOutlet internal weak var mapView: MKMapView!

	// MARK: - View Events

	override internal func viewDidLoad() {
		super.viewDidLoad()
		FlickrAPIClient.sharedClient.searchPhotosByLocation(tlPinAnnoView!.annotation!.coordinate, completionHandler: searchPhotosByLocationCompletionHandler)
	}

	// MARK: - Private:  Completion Handlers as Computed Variables

	private var searchPhotosByLocationCompletionHandler: APIDataTaskWithRequestCompletionHandler {

		return { (result, error) -> Void in

			guard error == nil else {
				self.presentAlert("Unable to obtain photos", message: error!.localizedDescription)
				return
			}

			guard result != nil else {
				self.presentAlert("Unable to obtain photos", message: "JSON data unavailable")
				return
			}

			let JSONResult = result as! JSONDictionary

			guard JSONResult["stat"] as! String == "ok" else {
				self.presentAlert("Unable to obtain photos", message: "JSON data unavailable")
            return
			}

			if let photosRecord = JSONResult["photos"] as! JSONDictionary? {
				let numOfPhotos = Int(photosRecord["total"] as! String)
				if numOfPhotos > 0 {
					let photos = photosRecord["photo"] as! [JSONDictionary]
					print("\(photos)")
				}

			} else {
				// present error
			}

		}

	}

}



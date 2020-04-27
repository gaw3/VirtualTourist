//
//  StringExtensions.swift
//  VirtualTourist
//
//  Created by Gregory White on 4/15/20.
//  Copyright © 2020 Gregory White. All rights reserved.
//

import Foundation

extension String {
    
    enum ActionTitle {
        static let ok  = "OK"
    }
    
    enum AlertMessage: String {
        case noPlacemarks      = "Did not receive any placemarks"
        case serverError       = "Server Error"
        case tapDoneButton     = "Tap the Done button when finished"
        case whileInDeleteMode = "While in deletion mode"
        case atThisLocation    = "At this location"
    }
    
    enum AlertTitle: String {
        case badGeocode    = "Unable to geocode location"
        case cannotDropPin = "Cannot drop pin"
        case tapPins       = "Tap Pins to Delete"
        case noPhotos      = "No Photos To Display"
    }
    
    enum HTTPMethod {
        static let get = "GET"
    }

    enum ReuseID {
        static let markerAnnoView = "MarkerAnnotationView"
        static let photoCell      = "PhotoCell"
    }
    
    enum StoryboardID {
        static let photosVC = "PhotosVC"
    }
    
    static let annoClusteringID = "ClusterID"
}

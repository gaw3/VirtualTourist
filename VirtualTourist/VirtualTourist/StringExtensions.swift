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
        case reverseGeocodingError       = "Reverse geocoding error"
        case tapDoneButton     = "Tap the Done button when finished"
        case whileInDeleteMode = "While in deletion mode"
        case atThisLocation    = "At this location"
        case dbError           = "Database error"
    }
    
    enum AlertTitle: String {
        case badReverseGeocode    = "Unable to determine location from coordinates"
        case cannotDropMarker = "Cannot drop marker"
        case tapMarkers       = "Tap markers to delete"
        case noPhotos      = "No photos to display"
        case unableToFetchLocations = "Unable to get saved locations"
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

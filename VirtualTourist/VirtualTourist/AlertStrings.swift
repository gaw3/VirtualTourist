//
//  AlertStrings.swift
//  VirtualTourist
//
//  Created by Gregory White on 2/25/17.
//  Copyright © 2017 Gregory White. All rights reserved.
//

import Foundation

struct Alert {
    
    struct ActionTitle {
        static let OK = "OK"
    }
    
    struct Message {
        static let TapDoneButton     = "Tap the Done button when finished"
        static let WhileInDeleteMode = "While in Pin Deletion Mode"
        static let NoJSONData        = "JSON data unavailable"
    }
    
    struct Title {
        static let BadFetch      = "Unable to access app database"
        static let TapPins       = "Tap Pins to Delete"
        static let CannotDropPin = "Cannot Drop Pin"
        static let NoPhotos      = "Unable to obtain photos"
    }
    
}

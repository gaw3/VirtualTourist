//
//  TravelogueCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Gregory White on 3/24/16.
//  Copyright © 2016 Gregory White. All rights reserved.
//

import UIKit

final class TravelogueCollectionViewCell: UICollectionViewCell {
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageView:		  UIImageView!
    
    // MARK: - Variables
    
    var title:     String?
    var URLString: String?
    
    var taskToCancelIfCellIsReused: URLSessionTask? {
        
        didSet {
            if let taskToCancel = oldValue {
                taskToCancel.cancel()
            }
            
        }
        
    }
    
}

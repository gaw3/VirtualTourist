//
//  PhotoCell.swift
//  VirtualTourist
//
//  Created by Gregory White on 4/21/20.
//  Copyright © 2020 Gregory White. All rights reserved.
//

import UIKit

final class PhotoCell: UICollectionViewCell {
    
    // MARK: - IB Outlets

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageView:         UIImageView!
    
    // MARK: - Variables

    var taskToCancelIfCellIsReused: NetworkTask2? {
        
        didSet {
            if let taskToCancel = oldValue {
                taskToCancel.cancel()
            }
            
        }
        
    }
    
    // MARK: - API

    func configure(withPhoto vtPhoto: VTPhoto) {
        
        if let imageData = vtPhoto.imageData,
           let image = UIImage(data: imageData) {
            imageView.image = image
            imageView.alpha = isSelected ? 0.3 : 1.0
        } else {
            imageView.image = nil
            activityIndicator.startAnimating()
            
            let networkTask = FlickrClient().getImageDownloadTask(forPhoto: vtPhoto, completionHandler: processImage(forPhoto: vtPhoto))
            networkTask.resume()
        }
        
    }
    
}



// MARK: -
// MARK: - Private Completion Handlers

private extension PhotoCell {
    
    func processImage(forPhoto vtPhoto: VTPhoto) -> NetworkTaskCompletionHandler {
        
        return { [weak self] (result, error) -> Void in
            
            guard let strongSelf = self else { return }
            
            DispatchQueue.main.async(execute: {
                strongSelf.activityIndicator.stopAnimating()
                
                guard error == nil else {
                    print("unable to download photo, error = \(error!)")
                    // TODO: put broken image placeholder in there
                    return
                }
                
                guard result != nil else {
                    print("expected image data was not received")
                    // TODO: put broken image placeholder in there
                    return
                }
                
                guard let image = UIImage(data: result!) else {
                    print("received corrupted image data")
                    // TODO: put broken image placeholder in there
                    return
                }
                
                strongSelf.imageView.image = image
                strongSelf.imageView.alpha = 1.0
                vtPhoto.imageData          = image.jpegData(compressionQuality: 1.0)
                
                coreData.save()
            })
            
        }
        
    }
    
}

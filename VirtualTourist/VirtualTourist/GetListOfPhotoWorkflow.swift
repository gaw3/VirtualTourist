//
//  GetListOfPhotoWorkflow.swift
//  VirtualTourist
//
//  Created by Gregory White on 4/22/20.
//  Copyright © 2020 Gregory White. All rights reserved.
//

import UIKit

enum GetListOfPhotosWorkflowState {
    case success
}

// MARK: -
// MARK: -

protocol GetListOfPhotosWorkflowDelegate: class {
    func process(_ response: GetListOfPhotosResponse, forLocation location: VTLocation)
}

// MARK: -
// MARK: -

final class GetListOfPhotosWorkflow: NSObject {

    private weak var delegate: GetListOfPhotosWorkflowDelegate!
    private      var location: VTLocation?
    
    init(delegate: GetListOfPhotosWorkflowDelegate) {
        self.delegate = delegate
    }
    
    func getListOfPhotos(forLocation location: VTLocation) {
        let flickr = FlickrClient()
        
        flickr.getListOfPhotos(at: location, completionHandler: processListOfPhotos(forLocation: location))
    }
    
}



// MARK: -
// MARK: - Private Completion Handlers

private extension GetListOfPhotosWorkflow {
    
    func processListOfPhotos(forLocation location: VTLocation) -> NetworkTaskCompletionHandler {
        
        return { [weak self] (result, error) -> Void in
            
            guard let strongSelf = self else { return }
            
            guard error == nil else {
                assertionFailure("error downloading list of photos, error = \(error!)")
                // TODO: delegate.process error
                return
            }
            
            guard result != nil else {
                assertionFailure("did not receive expected list of photos")
                // TODO: delegate.process error
                return
            }
            
            let decoder = JSONDecoder()
            
            do {
                let response = try decoder.decode(GetListOfPhotosResponse.self, from: result!)
                
                guard response.isOK else {
                    assertionFailure("status of response is not OK")
                    // TODO: delegate.process error
                    return
                }
                
                strongSelf.delegate.process(response, forLocation: location)
            } catch let error as NSError {
                assertionFailure("unable to decode JSON, error = \(error)")
                // TODO: delegate.process error
            }
            
        }
        
    }
    
}


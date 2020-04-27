# ![][AppIcon]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;VirtualTourist

VirtualTourist allows the user to place a marker on a map, and then download photos from Flickr that are tagged with this location.  The photos and their relationship with the location of the marker are persisted across app sessions via Core Data.

## Project

VirtualTourist is Portfolio Project #4 of the Udacity iOS Developer Nanodegree Program.  The following list contains pertinent course documents:

* [Udacity App Specification][AppSpec]
* [Udacity Grading Rubric][GradingRubric]
* [GitHub Swift Style Guide][SwiftStyleGuide]
* [Udacity Git Commit Message Style Guide][CommitMsgStyleGuide]
* [Udacity Project Review][ProjectReview]<br/><br/>

| [Change Log][ChangeLog] | Current Build          | Project Submission - ***Meets Expectations*** | 
| :----------             | :-----------------     | :-------------                                | 
| GitHub Tag              | v3.0                   | v1.0                                          | 
| App Version:            | 3.0                    | 1.0                                           | 
| Environment:            | iOS 13.4 / Swift 5     | iOS 9.3 / Swift 2                             | 
| Devices:                | iPhone Only            | iPhone Only                                   | 
| Orientations:           | Portrait Only          | Portrait Only                                 | 

## Design

### Data Persistence

The app's data persistence apparatus is comprised of the following:

* Core Data - manages data from the following relational entity–attribute model:
  - Travel Location - location ID, lat/long and other data.  A Travel Location may be related to zero, one or many Travel Photos.
  - Travel Photo - photo ID, URL & downloaded image data.  A Travel Photo must be related to one and only one Travel Location.

### Travel Locations View

TABLE 1 - Travel Locations View 

| **Travel Locations View** | **Pin Deletion Mode** | 
| :-----------------------: | :-------------------: |
| ![][TravLocsView]         | ![][Pin2Delete]       | 

TABLE 2 - Navigation Bar Buttons 

| Refresh            | Trash            |
| :---:              | :---:            |
| ![][RefreshButton] | ![][TrashButton] | 

Upon app launch, the initial view is the **Travel Locations View**.  A map view is presented, and markers are placed at any Travel Locations that were saved at the end of the previous app session.  

* Tap & hold (i.e. long press) a spot on the map to place a marker at that location & to save that Travel Location in Core Data.
* Tap a marker to display its callout.
* Tap the right callout accessory in order to transition to the **Travelogue View** in order to display photos associated with the marker's location.
* Tap the **Trash** button in the navigation bar to enter **Marker Deletion Mode**.  Instructions for using this mode appear in an alert view, tap **OK** to dismiss.  Tap a marker in this mode to remove the Travel Location & any related Travel Photos from Core Data.

### Travelogue View

TABLE 3 - Travelogue View : Present Images

| **Travelogue View** | **Images Actively Downloading**  | **No Photos**  |
| :-----------------: | :------------------------------: | :-----------:  |
| ![][TravView]       | ![][ActInds]                     | ![][EmptyTrav] |

This view consists of a map segment with a marker placed at the Travel Location and a collection of up to 21 images that are related to the Travel Location.

* Tap the **< OK** button in the navigation bar at any time to return to the **Travel Locations View**.
* Tap the **Refresh** button in the navigation bar in order to download a new group of images from Flickr.
  - Current set of photos are disassocited from their travel location and deleted from Core Data.
  - 21 images are requested;  however, any number ⋲ [0, 21] of images returned is valid.<br/><br/>
  - New images are stored in Core Data and associated with the travel location.
* When a collection cell is waiting for its assigned image to be downloaded, the cell is blue with an animating white activity indicator in the center.


TABLE 4 - Travelogue View : Delete Images

| **Delete Selected Photos** | 
| :------------------------: | 
| ![][SelPhotos]             | 

* Only *selected* photos can be deleted.
* A *selected* photo appears to be washed out as compared to a *deselected* photo.
* Tapping a photo alternates its *selected/deselected* status.
* The **Trash** button is available only if at least one photo is *selected*.
* Tap the available **Trash** button to remove the selected photos from Core Data and the collection view.

### iOS Frameworks & Grand Central Dispatch

* CoreData
* CoreGraphics
* CoreLocation
* Foundation
* Grand Central Dispatch
* MapKit
* UIKit

### Web APIs

[Flickr API][FlickrAPI] - Use as public source of photos.  Get photos tagged with a given lat/long.  [Website][FlickrWebsite] and [Terms of Service][FlickrTermsOfService].

### 3rd-Party

* *GitHub Swift Style Guide* lives in this [repo][StyleGuideRepo].
* `Swift.gitignore`, the template used to create the local `.gitignore` file, lives in this [repo][GitIgnoreRepo].

---
**Copyright © 2016-2020 Gregory White. All rights reserved.**





[ChangeLog]:             ./Paperwork/READMEFiles/ChangeLog.md

[CoreData]:              ./Paperwork/READMEFiles/CoreData.md
[Foundation]:            ./Paperwork/READMEFiles/Foundation.md
[GCD]:                   ./Paperwork/READMEFiles/GCD.md
[MapKit]:                ./Paperwork/READMEFiles/MapKit.md
[UIKit]:                 ./Paperwork/READMEFiles/UIKit.md

[ActInds]:               ./Paperwork/images/ActivityIndicators_300x534.png
[AppIcon]:               ./Paperwork/images/VirtualTourist_80.png
[EmptyTrav]:             ./Paperwork/images/EmptyTravelogue_300x534.png
[Pin2Delete]:            ./Paperwork/images/TapPinToDelete_300x534.png
[RefreshButton]:         ./Paperwork/images/RefreshButtonIcon_50.png
[SelPhotos]:             ./Paperwork/images/SelectedPhotos_300x534.png
[TrashButton]:           ./Paperwork/images/TrashButtonIcon_50.png
[TravLocsView]:          ./Paperwork/images/TravelLocationsView_300x534.png
[TravView]:              ./Paperwork/images/TravelogueView_300x534.png

[AppSpec]:               ./Paperwork/Udacity/UdacityAppSpecification.pdf
[CommitMsgStyleGuide]:   ./Paperwork/Udacity/UdacityGitCommitMessageStyleGuide.pdf
[GradingRubric]:         ./Paperwork/Udacity/UdacityGradingRubric.pdf
[ProjectReview]:         ./Paperwork/Udacity/UdacityProjectReview.pdf
[SwiftStyleGuide]:       ./Paperwork/Udacity/GitHubSwiftStyleGuide.pdf  

[FlickrAPI]:             https://www.flickr.com/services/api/
[FlickrTermsOfService]:  https://policies.yahoo.com/us/en/yahoo/terms/utos/index.htm
[FlickrWebsite]:         https://www.flickr.com/
[GitIgnoreRepo]:         https://github.com/github/gitignore
[StyleGuideRepo]:        https://github.com/github/swift-style-guide



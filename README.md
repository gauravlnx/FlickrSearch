# FlickrSearch for iOS

## Prereqs

- Xcode 9.0
- iOS 11+

## Running

1. Open `FlickrSearch.xcodeproj` from the root directory of the repo in Xcode.
2. Press the "Play" button in the top left or press command-r.

## Overall Architecture 

App is based on **MVP** architecture. Structure is broken down by the general purpose of contained source files. Here is a list of the high level groups and is contained in each.

1. **Features** : contains group of classes for individual screens.
2. **Service** : includes classes that are responsible for interacting with the network.
3. **Model** : contains all model objects for the app. All of the model classes implements `Codable` protocol available in Swift 4.
4. **Shared** : Contains helper classes and configurations.
5. **Nibs** : Contains storyboard and Xibs for features.

## Unit tests

Unit tests are written for FlickrViewPresenter only.
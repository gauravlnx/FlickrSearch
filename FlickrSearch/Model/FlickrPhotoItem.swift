//
//  FlickrPhotoItem.swift
//  FlickrSearch
//
//  Created by Gaurav Singh on 21/07/18.
//  Copyright © 2018 Gaurav Singh. All rights reserved.
//

import Foundation

struct FlickrPhotoItem: Codable {
    
    var id: String
    var farm: Int
    var server: String
    var secret: String
    
    var photoURL: URL? {
        get {
            return URL(string: "https://farm\(farm).static.flickr.com/\(server)/\(id)_\(secret).jpg")
        }
    }
    
    /**
     * Thumbnail URL
     */
    var photoURLSmall: URL? {
        get {
            return URL(string: "https://farm\(farm).static.flickr.com/\(server)/\(id)_\(secret)_t.jpg")
        }
    }
    
}

// Temporary

struct FlickrPhotosSearchResult: Codable {
    let photos : FlickrPhotoPagedResult
}

struct FlickrPhotoPagedResult: Codable {
    let photo : [FlickrPhotoItem]
}

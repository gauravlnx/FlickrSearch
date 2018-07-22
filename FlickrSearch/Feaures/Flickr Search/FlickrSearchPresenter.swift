//
//  FlickrSearchPresenter.swift
//  FlickrSearch
//
//  Created by Gaurav Singh on 21/07/18.
//  Copyright © 2018 Gaurav Singh. All rights reserved.
//

import Foundation

protocol FlickrSearchView: NSObjectProtocol {
    
    func searchViewDidStartLoading(isNewSearch: Bool)
    func searchViewDidFinishedLoading(isNewSearch: Bool, urls: [URL]?, error: Error?)
}

class FlickrSearchPresenter {
    
    weak private var flickrSearchView: FlickrSearchView?
    private var service: FlickrService
    
    private var flickrPhotos = [FlickrPhotoItem]()
    private var canLoadMore = false
    private var isLoading = false
    
    init(service: FlickrService) {
        self.service = service
    }
    
    func attachView(view: FlickrSearchView) {
        flickrSearchView = view
    }
    
    func searchFlickr(forQuery query: String) {
        flickrSearchView?.searchViewDidStartLoading(isNewSearch: true)
        isLoading = true
        service.searchPhotosFor(query: query) { [weak self] (photoItems, error) in
            
            if let items = photoItems {
                self?.flickrPhotos = items
                self?.canLoadMore = true
            } else {
                self?.canLoadMore = false
            }
            
            let urls = photoItems?.flatMap({ (photoItem) -> URL? in
                return photoItem.photoURLSmall
            })
            self?.flickrSearchView?.searchViewDidFinishedLoading(isNewSearch: true, urls: urls, error: error)
            self?.isLoading = false
        }
    }
    
    func loadMore() {
        guard canLoadMore, !isLoading else {
            return
        }
        
        flickrSearchView?.searchViewDidStartLoading(isNewSearch: false)
        isLoading = true
        service.loadMore { [weak self] (photoItems, error) in
            if let items = photoItems {
                self?.flickrPhotos.append(contentsOf: items)
                self?.canLoadMore = true
            } else {
                self?.canLoadMore = false
            }
            
            let urls = photoItems?.flatMap({ (photoItem) -> URL? in
                return photoItem.photoURLSmall
            })
            self?.flickrSearchView?.searchViewDidFinishedLoading(isNewSearch: false, urls: urls, error: error)
            self?.isLoading = false
        }
    }
    
    func getImageURL(atIndex index: UInt) -> URL? {
        if index < flickrPhotos.count {
            let photoItem = flickrPhotos[Int(index)]
            return photoItem.photoURL
        } else {
            return nil
        }
    }
    
}

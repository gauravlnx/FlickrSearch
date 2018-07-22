//
//  FlickrService.swift
//  FlickrSearch
//
//  Created by Gaurav Singh on 21/07/18.
//  Copyright © 2018 Gaurav Singh. All rights reserved.
//

import Foundation

class FlickrService {
    
    private var query: String?
    private var page = 1
    
    func searchPhotosFor(query: String, completion: @escaping ([FlickrPhotoItem]?, Error?) -> Void) {
        
        // If the query string is empty, return
        guard !query.isEmpty else {
            completion(nil, FSError.invalidArguments)
            return
        }
        self.query = query
        page = 1
        searchPhotos(forQuery: query, page: 1, completion: completion)
    }
    
    func loadMore(completion: @escaping ([FlickrPhotoItem]?, Error?) -> Void) {
        guard let query = self.query, !query.isEmpty else {
            completion(nil, FSError.invalidArguments)
            return
        }
        searchPhotos(forQuery: query, page: page + 1) { [weak self] (photoItems, error) in
            if photoItems?.count ?? 0 > 0 {
                self?.page += 1
            }
            completion(photoItems, error)
        }
    }
    
    private func searchPhotos(forQuery query: String, page: Int, completion: @escaping ([FlickrPhotoItem]?, Error?) -> Void) {
        
        // query may contain spaces. Hence percent encode it before using it in URL
        guard
            let queryString = query.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
            let url = URL(string: "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(Configuration.FLICKR_API_KEY)&%20format=json&nojsoncallback=1&safe_search=1&page=\(page)&text=\(queryString)") else {
                completion(nil, FSError.invalidArguments)
            return
        }
        
        let session = URLSession.shared
        session.dataTask(with: url) { (data, response, error) in
            guard
                let responseData = data,
                let flickrSearchResult = try? JSONDecoder().decode(FlickrPhotosSearchResult.self, from: responseData) else {
                DispatchQueue.main.async {
                    completion(nil, error ?? FSError.invalidResponse)
                }

                return
            }
            
            DispatchQueue.main.async {
                completion(flickrSearchResult.photos.photo, nil)
            }
        }.resume()
        
    }
    
}

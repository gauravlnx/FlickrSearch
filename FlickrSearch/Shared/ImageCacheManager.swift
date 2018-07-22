//
//  ImageCacheManager.swift
//  FlickrSearch
//
//  Created by Gaurav Singh on 21/07/18.
//  Copyright © 2018 Gaurav Singh. All rights reserved.
//

import UIKit

class ImageCacheManager {
    
    private let cache = NSCache<NSString, UIImage>()
    
    private let downloadQueue: OperationQueue
    
    static let shared = ImageCacheManager()
    
    private init() {
        downloadQueue = OperationQueue()
        downloadQueue.qualityOfService = .userInitiated
    }
    
    func loadImage(forURL url: URL, completion: @escaping (UIImage?) -> Void) {
        
        let key = url.absoluteString as NSString
        if let cacheImage = cache.object(forKey: key) {
            completion(cacheImage)
        } else {
            
            let downloadOperation = BlockOperation(block: { [weak self] in
                guard
                    let data = try? Data(contentsOf: url),
                    let image = UIImage(data: data) else {
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                    return
                }
                DispatchQueue.main.async {
                    self?.cache.setObject(image, forKey: key)
                    completion(image)
                }
            });
            downloadQueue.addOperation(downloadOperation)
        }
    }
    
}

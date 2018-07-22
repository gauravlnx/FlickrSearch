//
//  NSObject.swift
//  FlickrSearch
//
//  Created by Gaurav Singh on 21/07/18.
//  Copyright © 2018 Gaurav Singh. All rights reserved.
//

import Foundation

extension NSObject {
    var className: String {
        return String(describing: type(of: self))
    }
    
    class var className: String {
        return String(describing: self)
    }
}

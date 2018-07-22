//
//  FSError.swift
//  FlickrSearch
//
//  Created by Gaurav Singh on 21/07/18.
//  Copyright © 2018 Gaurav Singh. All rights reserved.
//

import Foundation

enum FSError: Error {
    case invalidArguments
    case invalidResponse
    case unknownResponse
}

extension FSError: LocalizedError {
    public var errorDescription: String? {
        get {
            switch self {
            case .invalidArguments:
                return "Failed due to invalid arguments"
            case .invalidResponse:
                return "Error due to invalid response"
            default:
                return "Unknown error. Please check your network."
            }
        }
    }
}

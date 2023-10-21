//
//  APIError.swift
//  Diary
//
//  Created by Max, Hemg on 2023/09/13.
//
import Foundation

enum APIError: Error {
    case invalidURL
    case requestFailure
    case invalidData
    case dataTransferFailure
    case invalidHTTPStatusCode
    case requestTimeOut
    
    var message: String? {
        switch self {
        case .invalidURL:
            return NSLocalizedString("invalidURL", comment: "")
        case .requestFailure:
            return NSLocalizedString("requestFailure", comment: "")
        case .invalidData:
            return NSLocalizedString("invalidData", comment: "")
        case .dataTransferFailure:
            return NSLocalizedString("dataTransferFailure", comment: "")
        case .invalidHTTPStatusCode:
            return NSLocalizedString("invalidHTTPStatusCode", comment: "")
        case . requestTimeOut:
            return NSLocalizedString("requestTimeOut", comment: "")
        }
    }
}

//
//  Error.swift
//  Diary
//
//  Created by Max, Hemg on 2023/08/30.
//

import Foundation

enum DecodingError: Error {
    case fileNotFound
    case decodingFailure
    case unknown

    var message: String {
        switch self {
        case .fileNotFound:
            return NSLocalizedString("fileNotFound", comment: "")
        case .decodingFailure:
            return NSLocalizedString("decodingFailure", comment: "")
        case .unknown:
            return NSLocalizedString("unknownError", comment: "")
        }
    }
}

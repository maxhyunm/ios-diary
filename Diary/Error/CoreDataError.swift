//
//  CoreDataError.swift
//  Diary
//
//  Created by Max, Hemg on 2023/09/10.
//

import Foundation

enum CoreDataError: Error {
    case dataNotFound
    case saveFailure
    case deleteFailure
    case unknown
    
    var alertTitle: String {
        switch self {
        case .dataNotFound:
            return NSLocalizedString("dataNotFoundTitle", comment: "")
        case .saveFailure:
            return NSLocalizedString("saveFailureTitle", comment: "")
        case .deleteFailure:
            return NSLocalizedString("deleteFailureTitle", comment: "")
        case .unknown:
            return NSLocalizedString("unknownErrorTitle", comment: "")
        }
    }

    var message: String {
        switch self {
        case .dataNotFound:
            return NSLocalizedString("dataNotFound", comment: "")
        case .saveFailure:
            return NSLocalizedString("saveFailure", comment: "")
        case .deleteFailure:
            return NSLocalizedString("deleteFailure", comment: "")
        case .unknown:
            return NSLocalizedString("unknownError", comment: "")
        }
    }
}

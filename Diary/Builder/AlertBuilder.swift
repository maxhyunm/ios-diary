//
//  AlertBuilder.swift
//  Diary
//
//  Created by Min Hyun on 2023/09/17.
//

import UIKit

final class AlertBuilder {
    private let viewController: UIViewController
    private let alertController: UIAlertController
    
    private var type: AlertType?
    private var alertActions: [UIAlertAction] = []
    
    init(viewController: UIViewController, prefferedStyle: UIAlertController.Style) {
        self.viewController = viewController
        self.alertController = UIAlertController(title: nil, message: nil, preferredStyle: prefferedStyle)
    }
    
    func setType(_ type: AlertType) {
        self.type = type
    }
    
    func addAction(_ actionType: AlertActionType, action: ((UIAlertAction) -> Void)? = nil) {
        let action = UIAlertAction(title: actionType.title, style: actionType.style, handler: action)
        alertActions.append(action)
    }
    
    @discardableResult
    func show() -> Self {
        alertController.title = type?.title
        alertController.message = type?.message
        alertActions.forEach { alertController.addAction($0) }
        
        viewController.present(alertController, animated: true)
        
        return self
    }
}

extension AlertBuilder {
    enum AlertType {
        case decodingError(error: DecodingError)
        case apiError(error: APIError)
        case coreDataError(error: CoreDataError)
        case delete
        case actionSheet
        
        var title: String? {
            switch self {
            case .decodingError, .apiError:
                return NSLocalizedString("networkError", comment: "")
            case .coreDataError(let error):
                return error.alertTitle
            case .delete:
                return NSLocalizedString("deleteTitle", comment: "")
            case .actionSheet:
                return nil
            }
        }
        
        var message: String? {
            switch self {
            case .decodingError(let error):
                return error.message
            case .apiError(let error):
                return error.message
            case .coreDataError(let error):
                return error.message
            case .delete:
                return NSLocalizedString("deleteMessage", comment: "")
            case .actionSheet:
                return nil
            }
        }
    }
    
    enum AlertActionType {
        case confirm
        case cancel
        case share
        case delete
        
        var title: String {
            switch self {
            case .confirm:
                return NSLocalizedString("confirm", comment: "")
            case .cancel:
                return NSLocalizedString("cancel", comment: "")
            case .share:
                return NSLocalizedString("share", comment: "")
            case .delete:
                return NSLocalizedString("delete", comment: "")
            }
        }
        
        var style: UIAlertAction.Style {
            switch self {
            case .cancel:
                return .cancel
            case .delete:
                return .destructive
            default:
                return .default
            }
        }
    }
}

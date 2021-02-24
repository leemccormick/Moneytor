//
//  UserError.swift
//  Moneytor
//
//  Created by Lee McCormick on 2/24/21.
//

import Foundation

enum UserError: Error {
    case ckError(Error)
    case cloudNotUpwrap
    case unexpectedRecordsFound
    case noUserLoggedIn
    case noUserForHype
    
    var errorDescription: String {
        switch self {
        case .ckError(let error):
            return error.localizedDescription
        case .cloudNotUpwrap:
            return "Could not upwrap the User data."
        case .unexpectedRecordsFound:
            return "Unexpected User records found. Got back different data that we thought we would."
        case .noUserLoggedIn:
            return "No user loogged In, Check current user!"
        case .noUserForHype:
            return "No user was found to be associated with this Hype."
        }
    }
}

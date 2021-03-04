//
//  User.swift
//  Moneytor
//
//  Created by Lee McCormick on 2/23/21.
//

import CloudKit
import UIKit

struct UserStrings {
    static let recordTypeKey = "User"
    fileprivate static let  fullNameKey = "fullName"
    fileprivate static let usernameKey = "username"
    fileprivate static let emailKey = "email"
    fileprivate static let passwordKey = "password"
    static let appleUserRefKey = "appleUserRef"
}

class User {
    var fullName: String
    var username: String
    var email: String
    var password: String
    var recordID: CKRecord.ID
    var appleUserRef: CKRecord.Reference
    
    init(fullname: String, username: String, email: String, password: String, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), appleUserRef: CKRecord.Reference) {
        self.fullName = fullname
        self.username = username
        self.email = email
        self.password = password
        self.recordID = recordID
        self.appleUserRef = appleUserRef
    }
}
// USING CKRecord to convert the data to USER TYPE And CKUSER in the cloud
// MARK: - Extension User
extension User {
    convenience init?(ckRecord: CKRecord) {
        guard let fullName = ckRecord[UserStrings.fullNameKey] as? String,
              let username = ckRecord[UserStrings.usernameKey] as? String,
              let email = ckRecord[UserStrings.emailKey] as? String,
              let password = ckRecord[UserStrings.passwordKey] as? String,
              let appleUserRef = ckRecord[UserStrings.appleUserRefKey] as? CKRecord.Reference else { return nil}
        
        self.init(fullname: fullName, username: username, email: email, password: password, appleUserRef: appleUserRef)
    }
}

extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.recordID == rhs.recordID
    }
}

// MARK: - Extension CKRecord
extension CKRecord {
    convenience init(user: User) {
        self.init(recordType: UserStrings.recordTypeKey, recordID: user.recordID)
        
        setValuesForKeys([
            UserStrings.fullNameKey : user.fullName,
            UserStrings.usernameKey : user.username,
            UserStrings.emailKey : user.email,
            UserStrings.passwordKey : user.password,
            UserStrings.appleUserRefKey : user.appleUserRef
        ])
    }
}

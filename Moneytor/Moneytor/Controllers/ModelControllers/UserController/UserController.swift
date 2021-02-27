//
//  UserController.swift
//  Moneytor
//
//  Created by Lee McCormick on 2/24/21.
//


import CloudKit
import UIKit

class UserController {
    
    // MARK: - Properties
    static let shared = UserController()
    var currentUser: User?
    let privateDB = CKContainer.default().privateCloudDatabase
    
    // MARK: - CRUD Methods
    // CREATE
    func createUserWith(_ fullName: String, username: String, email: String, password: String, completion: @escaping (Result<User?, UserError>) -> Void) {
        // Every apple account have a reference, we are grabbing thier appleIDrefernce.
        // We need to get the appleID reference in order to create the user
        fetchAppleUserRefernce { (result) in
            switch result {
            case .success(let reference):
                guard let reference = reference else { return completion(.failure(.noUserLoggedIn))}
                let newUser = User(fullname: fullName, username: username, email: email, password: password, appleUserRef: reference)
                let record = CKRecord(user: newUser)
                self.privateDB.save(record) { (record, error) in
                    if let error = error {
                        return completion(.failure(.ckError(error)))
                    }
                    guard let record = record else {return completion(.failure(.unexpectedRecordsFound))}
                    guard let savedUser = User(ckRecord: record) else {return completion(.failure(.cloudNotUpwrap))}
                    print("Create User: \(record.recordID.recordName)")
                    print("\nSUCCESSFULLY! CREATE USER IN THE CLOUDKIT.\n")
                    completion(.success(savedUser))
                }
            case .failure(let error) :
                print(error.localizedDescription)
            }
        }
    }
    
    // READ
    func fetchUser(completion: @escaping (Result<User?, UserError>) -> Void) {
        fetchAppleUserRefernce { (result) in
            switch result {
            case .success(let reference):
                guard let reference = reference else { return completion(.failure(.noUserLoggedIn))}
                let predicate = NSPredicate(format: "%K == %@", argumentArray: [UserStrings.appleUserRefKey, reference])
                let query = CKQuery(recordType: UserStrings.recordTypeKey, predicate: predicate)
                self.privateDB.perform(query, inZoneWith: nil) { (records, error) in
                    if let error = error {
                        return completion(.failure(.ckError(error)))
                    }
                    guard let record = records?.first else { return completion(.failure(.unexpectedRecordsFound))}
                    guard let foundUser = User(ckRecord: record) else { return completion(.failure(.cloudNotUpwrap))}
                    print("Fetched user: \(record.recordID.recordName)")
                    print("\nSUCCESSFULLY! FETCHED USER FORM THE CLOUDKIT.\n")
                    completion(.success(foundUser))
                }
            case .failure(let error):
                print(error.errorDescription)
            }
        }
    }
    
    // private ==> preventing ???
    private func fetchAppleUserRefernce(completion: @escaping (Result<CKRecord.Reference?, UserError>) -> Void) {
        // Using the default().fetchUserRecordID to fetch
        CKContainer.default().fetchUserRecordID { (recordID, error) in
            if let error = error {
                completion(.failure(.ckError(error)))
            }
            // if we have recordID
            if let recordID = recordID {
                // action: .deleteSelf ==> we are not deleting the record of user, just something in apple???
                let reference = CKRecord.Reference(recordID: recordID, action: .deleteSelf)
                print("\nSUCCESSFULLY! FETCHED APPLE USER REFERNCE FORM THE CLOUDKIT.\n")
                completion(.success(reference)) // Then return the reference ==> fetchAppleUserRefernce
            }
        }
    }
}

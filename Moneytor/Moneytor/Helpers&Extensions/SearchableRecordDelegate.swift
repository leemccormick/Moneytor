//
//  File.swift
//  Moneytor
//
//  Created by Lee McCormick on 2/25/21.
//

import Foundation

// MARK: - Protocol
protocol SearchableRecordDelegate {
    func matches(searchTerm: String, name: String, category: String, date: String, amount: String, note: String) -> Bool
}

extension SearchableRecordDelegate {
    func matches(searchTerm: String, name: String, category: String, date: String, amount: String, note: String) -> Bool{
//        let combinationSearchedResults = [name.trimmingCharacters(in: .whitespaces).lowercased(), category.trimmingCharacters(in: .whitespaces).lowercased(), date.trimmingCharacters(in: .whitespaces).lowercased(), amount, note.trimmingCharacters(in: .whitespaces).lowercased()]
        
//        print("\n===================searchTerm.lowercased()! \(searchTerm.lowercased().stringByRemovingWhitespaces) IN \(#function) ======================\n")
//        let fromGyukaku = "from gyukaku"
//        print(fromGyukaku.lowercased().trimmingCharacters(in: .whitespaces))
//        print(fromGyukaku.stringByRemovingWhitespaces)
        let nameCategoryDateNote = name + category + date + note
        let categoryNote = category + note
        let nameDateNote = name + date + note
        let nameNote = name + note
        if name.lowercased().contains(searchTerm.lowercased()) {
            return true
        } else if category.lowercased().contains(searchTerm.lowercased()){
            return true
        } else if date.lowercased().contains(searchTerm.lowercased()){
            return true
        } else if amount.lowercased().contains(searchTerm.lowercased()){
            return true
        } else if note.lowercased().contains(searchTerm.lowercased()){
            return true
        } else if nameCategoryDateNote.lowercased().stringByRemovingWhitespaces.contains(searchTerm.lowercased().stringByRemovingWhitespaces){
//            print("\n===================nameCategory.lowercased().stringByRemovingWhitespaces! \(nameCategoryDateNote.lowercased().stringByRemovingWhitespaces) IN\(#function) ======================\n")
            return true
        } else if categoryNote.lowercased().stringByRemovingWhitespaces.contains(searchTerm.lowercased().stringByRemovingWhitespaces){
//            print("\n===================nameCategory.lowercased().stringByRemovingWhitespaces! \(categoryNote.lowercased().stringByRemovingWhitespaces) IN\(#function) ======================\n")
            return true
        } else if nameNote.lowercased().stringByRemovingWhitespaces.contains(searchTerm.lowercased().stringByRemovingWhitespaces){
//            print("\n===================nameCategory.lowercased().stringByRemovingWhitespaces! \(nameNote.lowercased().stringByRemovingWhitespaces) IN\(#function) ======================\n")
            return true
        } else if nameDateNote.lowercased().stringByRemovingWhitespaces.contains(searchTerm.lowercased().stringByRemovingWhitespaces){
//            print("\n===================nameCategory.lowercased().stringByRemovingWhitespaces! \(nameDateNote.lowercased().stringByRemovingWhitespaces) IN\(#function) ======================\n")
            return true
        } else {
            return false
        }
    }
}

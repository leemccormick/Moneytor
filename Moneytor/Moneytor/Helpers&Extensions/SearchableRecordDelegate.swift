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
            return true
        } else if categoryNote.lowercased().stringByRemovingWhitespaces.contains(searchTerm.lowercased().stringByRemovingWhitespaces){
            return true
        } else if nameNote.lowercased().stringByRemovingWhitespaces.contains(searchTerm.lowercased().stringByRemovingWhitespaces){
            return true
        } else if nameDateNote.lowercased().stringByRemovingWhitespaces.contains(searchTerm.lowercased().stringByRemovingWhitespaces) {
            return true
        } else {
            return false
        }
    }
}

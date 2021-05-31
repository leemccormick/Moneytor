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
        let combinationSearchedResults = name.trimmingCharacters(in: .whitespaces) + category.trimmingCharacters(in: .whitespaces) + date.trimmingCharacters(in: .whitespaces) + amount + note.trimmingCharacters(in: .whitespaces)
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
        } else if combinationSearchedResults.lowercased().contains(searchTerm.lowercased()){
            print("\n===================combinationSearchedResults! \(combinationSearchedResults.lowercased().trimmingCharacters(in: .whitespaces)) IN \(#function) ======================\n")
           return true
        } else {
            return false
        }
    }
}

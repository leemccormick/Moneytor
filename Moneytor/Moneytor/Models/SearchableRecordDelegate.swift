//
//  File.swift
//  Moneytor
//
//  Created by Lee McCormick on 2/25/21.
//

import Foundation

// MARK: - Protocol
protocol SearchableRecordDelegate {
    func matches(searchTerm: String, name: String) -> Bool
}

extension SearchableRecordDelegate {
    func matches(searchTerm: String, name: String) -> Bool {
        if name.lowercased().contains(searchTerm.lowercased()) {
            return true
        } else {
            return false
        }
    }
}

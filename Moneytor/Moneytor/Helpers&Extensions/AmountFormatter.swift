//
//  AmountFormatter.swift
//  Moneytor
//
//  Created by Lee McCormick on 2/23/21.
//

import Foundation

struct AmountFormatter {
    
    static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.isLenient = true
        formatter.locale = Locale.current
        formatter.locale = Locale(identifier: "es_US")
        formatter.numberStyle = .currency
        return formatter
    }()
    
    static let numberIn2DecimalPlaces: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.isLenient = true
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    static let numberIn2DecimalPlacesAndNoGroupping: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.isLenient = true
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = false
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    static let numberInPercent: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.isLenient = true
        formatter.numberStyle = .percent
        return formatter
    }()
    
    static let numberInEachCurrency: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        return formatter
    }()
    
    static let numberNone: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .none
        return formatter
    }()
    
    static func percentInString(num: Double) -> String {
        let numberStringInPercent =  self.numberInPercent.string(for: num)
        return numberStringInPercent ?? "0 %"
    }
    
    static func currencyInString(num: Double) -> String {
        let numberStringInCurrency = self.numberInEachCurrency.string(from: NSNumber(value: num))
        return numberStringInCurrency ?? "$ 00.00"
    }
    
    static func twoDecimalPlaces(num: Double) -> String {
        let numberTwoDecimalPlaces = self.numberIn2DecimalPlacesAndNoGroupping.string(from: NSNumber(value: num))
        
        return numberTwoDecimalPlaces ?? "00.00"
    }
}



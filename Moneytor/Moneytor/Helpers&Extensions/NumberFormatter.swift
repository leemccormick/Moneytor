//
//  NumberFormatter.swift
//  Moneytor
//
//  Created by Lee McCormick on 2/23/21.
//

import Foundation

//extension NSNumber {
//
//    func doubleToString(format: NSNumber) -> String {
//        let formatter = NumberFormatter()
//        formatter.isLenient = true
//        formatter.numberStyle = .decimal
//        // minimum decimal digit, eg: to display 2 as 2.00
//        formatter.minimumFractionDigits = 2
//        // maximum decimal digit, eg: to display 2.5021 as 2.50
//        formatter.maximumFractionDigits = 2
//
//        return formatter.string(from: format) ?? "$00.00"
//    }
//
//
//    func doubleToCurrencyString(format: NSNumber) -> String {
//    let formatter = NumberFormatter()
//formatter.locale = Locale.current // Change this to another locale if you want to force a specific locale, otherwise this is redundant as the current locale is the default already
//formatter.numberStyle = .currency
//    return formatter.string(from: format) ?? "$00.00"
//}
//
//
//
//}


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
        // minimum decimal digit, eg: to display 2 as 2.00
        formatter.minimumFractionDigits = 2
        // maximum decimal digit, eg: to display 2.5021 as 2.50
        formatter.maximumFractionDigits = 2

        return formatter
    }()
    
    
    static let numberInPercent: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.isLenient = true
        formatter.numberStyle = .percent
        // minimum decimal digit, eg: to display 2 as 2.00
       // formatter.minimumFractionDigits = 1
        // maximum decimal digit, eg: to display 2.5021 as 2.50
//formatter.maximumFractionDigits = 1

        return formatter
    }()
    
    static let numberInEachCurrency: NumberFormatter = {
        let formatter = NumberFormatter()
    formatter.locale = Locale.current // Change this to another locale if you want to force a specific locale, otherwise this is redundant as the current locale is the default already
    formatter.numberStyle = .currency
        return formatter
    }()
    
//    static func doubleToStringInCurrency(amount: Double) {
//        self.numberFormatterIn2DecimalPlaces.string(from: NSNumber(value: ?? 0)) ?? ""
//    }
        
}



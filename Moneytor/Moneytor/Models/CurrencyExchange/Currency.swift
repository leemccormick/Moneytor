//
//  Currency.swift
//  Moneytor
//
//  Created by Lee McCormick on 3/9/21.
//

import Foundation

struct Currency: Codable {
    let rates: [Rate]
    let base: String
    
    enum CodingKeys: String, CodingKey {
        case rates = "conversion_rates"
        case base = "base_code"
    }
    
    struct Rate: Codable {
        let currency: Double
    }
}

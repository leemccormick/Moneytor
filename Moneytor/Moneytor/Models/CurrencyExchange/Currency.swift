//
//  Currency.swift
//  Moneytor
//
//  Created by Lee McCormick on 3/9/21.
//

import Foundation

struct CurrencyPair: Decodable {
    let baseCountryCode: String
    let targetCoutryCode: String
    let rate: Double
    let convertResult: Double
    enum CodingKeys: String, CodingKey {
        case baseCountryCode = "base_code"
        case targetCoutryCode = "target_code"
        case  rate = "conversion_rate"
        case convertResult = "conversion_result"
    }
}

enum CurrencyError: LocalizedError {
    case invalidURL
    case thrownError(Error)
    case noData
    case unableToDecode
    
    var errorDescription: String {
        switch self {
        case .invalidURL:
            return "The server failed to reach the necessary URL."
        case .thrownError(let error):
            return "Opps, there was an error: \(error.localizedDescription)"
        case .noData:
            return "The server failed to load any data."
        case .unableToDecode:
            return "There was an error when trying to load the data."
        }
    }
}

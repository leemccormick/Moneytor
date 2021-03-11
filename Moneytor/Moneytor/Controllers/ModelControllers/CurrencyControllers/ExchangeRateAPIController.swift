//
//  ExchangeRateAPIController.swift
//  Moneytor
//
//  Created by Lee McCormick on 3/11/21.
//

import Foundation
//
//  CurrencyController.swift
//  Moneytor
//
//  Created by Lee McCormick on 3/11/21.
//

import Foundation

class ExchangeRateAPIController {
    // static let shared = CurrencyController()
    static let baseURL = URL(string: "https://v6.exchangerate-api.com")
    static let version6 = "v6"
    static let apiKeyValue = "e5589afc2a2c9ee499a9171a"
    static let pair = "pair"
    var baseCountryCode: String = ""
    var rateString: String = ""
    var selectedCountryCode: String = ""
    var resultsConvert: Double = 0.0
    var resultConvertString: String = ""
    var baseCountryName: String = ""
    var selectedCountryName: String = ""
    
    
    static func fetchCurrencyPairConverter(baseCode: String, targetCode: String, amount: String, completion: @escaping (Result<CurrencyPair,CurrencyError>) -> Void ) {
        
        guard let baseURL = baseURL else {return completion(.failure(.invalidURL))}
        let versionURL = baseURL.appendingPathComponent(version6)
        let apiKeyURL = versionURL.appendingPathComponent(apiKeyValue)
        let pairURL = apiKeyURL.appendingPathComponent(pair)
        let baseCodeURL = pairURL.appendingPathComponent(baseCode)
        let targetCodeURL = baseCodeURL.appendingPathComponent(targetCode)
        let amountURL = targetCodeURL.appendingPathComponent(amount)
        
        
        let finalURL = amountURL
        
        print("----------------- amountURL:: \(finalURL)-----------------")
        
        URLSession.shared.dataTask(with: finalURL) { (data, response, error) in
            if let error = error {
                return completion(.failure(.thrownError(error)))
            }
            
            if let response = response as? HTTPURLResponse {
                print("FETCH PAIR REQUEST STATUS CODE : \(response.statusCode)")
            }
            
            guard let data = data else {return completion(.failure(.noData))}
            do {
                let currencyPair = try JSONDecoder().decode(CurrencyPair.self, from: data)
                return completion(.success(currencyPair))
            } catch {
                return completion(.failure(.thrownError(error)))
            }
        }.resume()
    }
    
    
    
}

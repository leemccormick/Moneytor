//
//  CurrencyController.swift
//  Moneytor
//
//  Created by Lee McCormick on 3/11/21.
//

import Foundation

class CurrencyController {
    
    static let shared = CurrencyController()

    var baseCountryCode: String = ""
    var rate: Double = 0.0
    var rateString: String = ""
    var selectedCountryCode: String = ""
    var resultsConvert: Double = 0.0
    var resultConvertString: String = ""
    var baseCountryName: String = ""
    var selectedCountryName: String = ""
    var currencyPair: CurrencyPair?
    
    let countryCodeDictionary = ["AED" : "United Arab Emirates",
                                 "AFN" : "Afghanistan",
                                 "ALL" : "Albania",
                                 "AMD" : "Armenia",
                                 "ANG" : "Netherlands Antilles",
                                 "AOA" : "Angola",
                                 "ARS" : "Argentina",
                                 "AUD" : "Australia",
                                 "AWG" : "Aruba",
                                 "AZN" : "Azerbaijan",
                                 "BAM" : "Bosnia and Herzegovina",
                                 "BBD" : "Barbados",
                                 "BDT" : "Bangladesh",
                                 "BGN" : "Bulgaria",
                                 "BHD" : "Bahrain",
                                 "BIF" : "Burundi",
                                 "BMD" : "Bermuda",
                                 "BND" : "Brunei",
                                 "BOB" : "Bolivia",
                                 "BRL" : "Brazil",
                                 "BSD" : "Bahamas",
                                 "BTN" : "Bhutan",
                                 "BWP" : "Botswana",
                                 "BYN" : "Belarus",
                                 "BZD" : "Belize",
                                 "CAD" : "Canada",
                                 "CDF" : "Democratic Republic of the Congo",
                                 "CHF" : "Switzerland",
                                 "CLP" : "Chile",
                                 "CNY" : "China",
                                 "COP" : "Colombia",
                                 "CRC" : "Costa Rica",
                                 "CUC" : "Cuba",
                                 "CUP" : "Cuba",
                                 "CVE" : "Cape Verde",
                                 "CZK" : "Czech Republic",
                                 "DJF" : "Djibouti",
                                 "DKK" : "Denmark",
                                 "DOP" : "Dominican Republic",
                                 "DZD" : "Algeria",
                                 "EGP" : "Egypt",
                                 "ERN" : "Eritrea",
                                 "ETB" : "Ethiopia",
                                 "EUR" : "European Union",
                                 "FJD" : "Fiji",
                                 "FKP" : "Falkland Islands",
                                 "FOK" : "Faroe Islands",
                                 "GBP" : "United Kingdom",
                                 "GEL" : "Georgia",
                                 "GGP" : "Guernsey",
                                 "GHS" : "Ghana",
                                 "GIP" : "Gibraltar",
                                 "GMD" : "The Gambia",
                                 "GNF" : "Guinea",
                                 "GTQ" : "Guatemala",
                                 "GYD" : "Guyana",
                                 "HKD" : "Hong Kong",
                                 "HNL" : "Honduras",
                                 "HRK" : "Croatia",
                                 "HTG" : "Haiti",
                                 "HUF" : "Hungary",
                                 "IDR" : "Indonesia",
                                 "ILS" : "Israel",
                                 "IMP" : "Isle of Man",
                                 "INR" : "India",
                                 "IQD" : "Iraq",
                                 "IRR" : "Iran",
                                 "ISK" : "Iceland",
                                 "JMD" : "Jamaica",
                                 "JOD" : "Jordan",
                                 "JPY" : "Japan",
                                 "KES" : "Kenya",
                                 "KGS" : "Kyrgyzstan",
                                 "KHR" : "Cambodia",
                                 "KID" : "Kiribati",
                                 "KMF" : "Comoros",
                                 "KRW" : "South Korea",
                                 "KWD" : "Kuwait",
                                 "KYD" : "Cayman Islands",
                                 "KZT" : "Kazakhstan",
                                 "LAK" : "Laos",
                                 "LBP" : "Lebanon",
                                 "LKR" : "Sri Lanka",
                                 "LRD" : "Liberia",
                                 "LSL" : "Lesotho",
                                 "LYD" : "Libya",
                                 "MAD" : "Morocco",
                                 "MDL" : "Moldova",
                                 "MGA" : "Madagascar",
                                 "MKD" : "North Macedonia",
                                 "MMK" : "Myanmar",
                                 "MNT" : "Mongolia",
                                 "MOP" : "Macau",
                                 "MRU" : "Mauritania",
                                 "MUR" : "Mauritius",
                                 "MVR" : "Maldives",
                                 "MWK" : "Malawi",
                                 "MXN" : "Mexico",
                                 "MYR" : "Malaysia",
                                 "MZN" : "Mozambique",
                                 "NAD" : "Namibia",
                                 "NGN" : "Nigeria",
                                 "NIO" : "Nicaragua",
                                 "NOK" : "Norway",
                                 "NPR" : "Nepal",
                                 "NZD" : "New Zealand",
                                 "OMR" : "Oman",
                                 "PAB" : "Panama",
                                 "PEN" : "Peru",
                                 "PGK" : "Papua New Guinea",
                                 "PHP" : "Philippines",
                                 "PKR" : "Pakistan",
                                 "PLN" : "Poland",
                                 "PYG" : "Paraguay",
                                 "QAR" : "Qatar",
                                 "RON" : "Romania",
                                 "RSD" : "Serbia",
                                 "RUB" : "Russia",
                                 "RWF" : "Rwanda",
                                 "SAR" : "Saudi Arabia",
                                 "SBD" : "Solomon Islands",
                                 "SCR" : "Seychelles",
                                 "SDG" : "Sudan",
                                 "SEK" : "Sweden",
                                 "SGD" : "Singapore",
                                 "SHP" : "Saint Helena",
                                 "SLL" : "Sierra Leone",
                                 "SOS" : "Somalia",
                                 "SRD" : "Suriname",
                                 "SSP" : "South Sudan",
                                 "STN" : "São Tomé and Príncipe",
                                 "SYP" : "Syria",
                                 "SZL" : "Eswatini",
                                 "THB" : "Thailand",
                                 "TJS" : "Tajikistan",
                                 "TMT" : "Turkmenistan",
                                 "TND" : "Tunisia",
                                 "TOP" : "Tonga",
                                 "TRY" : "Turkey",
                                 "TTD" : "Trinidad and Tobago",
                                 "TVD" : "Tuvalu",
                                 "TWD" : "Taiwan",
                                 "TZS" : "Tanzania",
                                 "UAH" : "Ukraine",
                                 "UGX" : "Uganda",
                                 "USD" : "United States",
                                 "UYU" : "Uruguay",
                                 "UZS" : "Uzbekistan",
                                 "VES" : "Venezuela",
                                 "VND" : "Vietnam",
                                 "VUV" : "Vanuatu",
                                 "WST" : "Samoa",
                                 "XAF" : "CEMAC",
                                 "XCD" : "Organisation of Eastern Caribbean States",
                                 "XDR" : "International Monetary Fund",
                                 "XOF" : "CFA",
                                 "XPF" : "Collectivités d'Outre-Mer",
                                 "YER" : "Yemen",
                                 "ZAR" : "South Africa",
                                 "ZMW" : "Zambia"
                                 ]
        

    
   func findCurrencyCodeByCountyName(_ selectedCountryName: String) -> String?{
        var selectedCurrencyCode = ""
        for country in countryCodeDictionary {
            if country.value == selectedCountryName {
                selectedCurrencyCode = country.key
            }
        }
        return selectedCurrencyCode
    }

     func findCountryNameByCurrencyCode(_ code: String) -> String {
        var countryName = ""
        for country in countryCodeDictionary {
            if country.key == code {
                countryName = country.value
            }
        }
        return countryName
    }

    func calculatedCurrencyFromSelectedCountry(selectedCountryName: String, totalAmountString: String) -> Void {
        let selectedCurrencyCode = findCurrencyCodeByCountyName(selectedCountryName)
        guard let selectedCode = selectedCurrencyCode else {return}
        ExchangeRateAPIController.fetchCurrencyPairConverter(targetCode: selectedCode, amount: totalAmountString) { (results) in
            switch results {
            case .success(let currencyPair):
                self.currencyPair = currencyPair
//                self.baseCountryCode = currencyPair.baseCountryCode
//                self.rate = currencyPair.rate
//                self.rateString = AmountFormatter.twoDecimalPlaces(num: self.rate)
//                self.selectedCountryCode = currencyPair.targetCoutryCode
//                self.resultsConvert = currencyPair.convertResult
//                self.resultConvertString = AmountFormatter.twoDecimalPlaces(num: self.resultsConvert)
//                self.baseCountryName = self.findCountryNameByCurrencyCode(self.baseCountryCode)
//                self.selectedCountryName = self.findCountryNameByCurrencyCode(self.selectedCountryCode)
//
//                print("baseCountryCode : \(currencyPair.baseCountryCode)")
//                print("rate :\(currencyPair.rate)")
//                print("targetCountry : \(currencyPair.targetCoutryCode)")
//                print("results : \(currencyPair.convertResult)")
//                print("----------------- baseCountryName :: \(self.baseCountryName)-----------------")
//                print("-----------------selectedCountryName :: \(selectedCountryName)-----------------")
            case .failure(let error):
            print(error.localizedDescription)
            }
        }
//
//        self.baseCountryCode = self.currencyPair.baseCountryCode
//                      self.rate = currencyPair.rate
//                     self.rateString = AmountFormatter.twoDecimalPlaces(num: self.rate)
//                  self.selectedCountryCode = currencyPair.targetCoutryCode
//                    self.resultsConvert = currencyPair.convertResult
//                  self.resultConvertString = AmountFormatter.twoDecimalPlaces(num: self.resultsConvert)
//        self.baseCountryName = self.findCountryNameByCurrencyCode(self.baseCountryCode)
//                    self.selectedCountryName = self.findCountryNameByCurrencyCode(self.selectedCountryCode)
        
    }

    
}

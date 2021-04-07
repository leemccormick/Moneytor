//
//  ReconizedTextScanner.swift
//  Moneytor
//
//  Created by Lee McCormick on 3/21/21.
//

import Foundation

struct ReconizedTextScanner: Hashable {
    var text: String
    var minY: Double
    var midY: Double
    var maxY: Double
    var index: Int
    
    init(text: String = "" , minY: Double = 0.0, midY: Double = 0.0, maxY: Double = 0.0, index: Int = 0) {
        self.text = text
        self.minY = minY
        self.midY = midY
        self.maxY = maxY
        self.index = index
    }
}

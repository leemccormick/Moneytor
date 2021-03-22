//
//  ScannerController.swift
//  Moneytor
//
//  Created by Lee McCormick on 3/21/21.
//

import Foundation
import Vision
import VisionKit

class ScannerController {
    
    static let shared = ScannerController()
    let textRecognizationQueue = DispatchQueue.init(label: "TextRecognizationQueue", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem, target: nil)
    var requests = [VNRequest]()
    var reconizedTexts: [ReconizedTextScanner] = []
    var previousReconizedTexts: ReconizedTextScanner?
    var name: String = ""
    var amount: String = ""
    var amountInDouble: Double = 0.0
    var date: String = ""
    var note: String = ""
    
    func setupVision() {
        
        let textRecognizationRequest = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                print("No Results Found!")
                return
            }
      var indexOfReconizedText: Int = 0
            let maximumCandidates = 1
            for observation in observations {
                let newScanner = ReconizedTextScanner()
                guard let candidate = observation.topCandidates(maximumCandidates).first else {continue}
                let text = candidate.string
                newScanner.text = text
             
                    let dObservationMinY = Double(observation.boundingBox.minY)
                newScanner.minY = dObservationMinY
                    let dObservationMidY = Double(observation.boundingBox.midY)
                newScanner.midY = dObservationMidY
                    let dObservationMaxY = Double(observation.boundingBox.maxY)
                newScanner.maxY = dObservationMaxY
                    
                do {
                    let types: NSTextCheckingResult.CheckingType = [.date]
                    let detector = try NSDataDetector(types: types.rawValue)
                    let matches = detector.matches(in: text, options: .init(), range: NSRange(location: 0, length: text.count))
                    if !matches.isEmpty {
                        self.date = text
                    } else {
                    }
                } catch {
                    print("\n==== ERROR IN \(#function) : \(error.localizedDescription) : \(error) ====\n")
                }
                indexOfReconizedText += 1
                newScanner.index += 1
            self.reconizedTexts.append(newScanner)
            }
            self.detectForNameAndAmount(reconizedTexts: self.reconizedTexts)
        }
        textRecognizationRequest.recognitionLevel = .accurate
        textRecognizationRequest.usesLanguageCorrection = true
        requests = [textRecognizationRequest]
    }
    
    
    func detectForNameAndAmount(reconizedTexts: [ReconizedTextScanner]) {
        var potentialAmounts: [Double] = []
        for result in reconizedTexts {
            self.note += result.text
            self.note += "\n"
            if result.index == 0 || result.index == 1 || result.index == 2 {
                self.name += result.text
            }
            let rSeparates = result.text.components(separatedBy: " ")
             for rSeparate in rSeparates {
                 
                 if rSeparate.isnumberordouble {
                     let num = Double(rSeparate)
                     if let upwrapNum = num {
                         if upwrapNum < 1000 {
                            potentialAmounts.append(upwrapNum)
                         }
                     }
                 }
                 if rSeparate.contains("$") {
                     var newR = rSeparate
                     newR.removeFirst()
                     let num = Double(newR)
                     if let upwrapNum = num {
                        potentialAmounts.append(upwrapNum)
                     }
                 }
             }
        }
        guard let amountIsThelastInPotentialAmounts = potentialAmounts.last else {return}
        self.amountInDouble = amountIsThelastInPotentialAmounts
    }
}


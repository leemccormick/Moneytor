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
   // var requests = [VNRequest]()
    var reconizedTexts: [ReconizedTextScanner] = []
    var previousReconizedTexts: ReconizedTextScanner?
    var name: String = ""
    var amount: String = ""
    var amountInDouble: Double = 0.0
    var date: String = ""
    var note: String = ""
    
    func setupVision() -> [VNRequest] {
        
        let textRecognizationRequest = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                print("No Results Found!")
                return
            }
     
            var indexOfReconizedText: Int = 0
            let maximumCandidates = 1
            for observation in observations {
              
                var newScanner = ReconizedTextScanner()
                guard let candidate = observation.topCandidates(maximumCandidates).first else {continue}
                let text = candidate.string
                newScanner.text = text
             
                let dObservationMinY = Double(observation.boundingBox.minY).round(to: 2)
                newScanner.minY = dObservationMinY
                let dObservationMidY = Double(observation.boundingBox.midY).round(to: 2)
                newScanner.midY = dObservationMidY
                let dObservationMaxY = Double(observation.boundingBox.maxY).round(to: 2)
                newScanner.maxY = dObservationMaxY
                newScanner.index = indexOfReconizedText
                
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
              
            self.reconizedTexts.append(newScanner)
                indexOfReconizedText += 1

            }
            self.detectForNameAndAmount(reconizedTexts: self.reconizedTexts)
            self.groupingFromTheSameLine(reconizedTexts: self.reconizedTexts)

        }
        textRecognizationRequest.recognitionLevel = .accurate
        textRecognizationRequest.usesLanguageCorrection = true
        let requests = [textRecognizationRequest]
        return requests
    }
    
    
    func detectForNameAndAmount(reconizedTexts: [ReconizedTextScanner]) {
        var potentialAmounts: [Double] = []
        
        for result in reconizedTexts {
           // print("-----------------result.index ::: \(result.index)-----------------\(#function)")
            //self.note += result.text
            //self.note += "\n"
            if result.index == 0 {
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
        self.amount = String(amountInDouble)
        //print("==================\n amountInDouble:: \(amountInDouble)\n=======================\(#function)")
        //print("==================\n amountInDouble:: \(amountInDouble)\n=======================\(#function)")
        //self.name.
    }
    
    func groupingFromTheSameLine(reconizedTexts: [ReconizedTextScanner]) {
       // let dictionary = Dictionary(grouping: reconizedTexts, by:  { $0 })
       // var previousResult
        
        var midYs: [Double] = []
        var minYs: [Double] = []
        var maxYs: [Double] = []
        let sortedReconizedTexts = reconizedTexts.sorted { $0.midY > $1.midY }
        for result in reconizedTexts {
            midYs.append(result.midY)
            minYs.append(result.minY)
            maxYs.append(result.maxY)
        }
        
        let newMidYs = midYs.removeDuplicates().sorted {$0 > $1}
        let newMinYs = minYs.removeDuplicates().sorted {$0 > $1}
        let newMaxYs = maxYs.removeDuplicates().sorted {$0 > $1}
        print("----------------- midYs:: \(newMidYs)-----------------")
        var newNote = ""
        //for n in newMidYs {
        var index = 0
        
        for r in sortedReconizedTexts {
             print("-----r :: \(r.text)   \t\tMidY:: \(r.midY) \t\tMinY:: \(r.minY) \t\tMaxY:: \(r.maxY)")
            
            if index < newMidYs.count - 1 {

                if newMidYs[index] == r.midY || newMinYs[index] == r.minY || newMaxYs[index] == r.maxY  {
                    newNote += "\t\t"
                    newNote += "\(r.text)"
                   // newNote += "\t"
                } else {
                    newNote += "\n"
                    newNote += "\(r.text)"
//                    newNote += "\n"
                   // newNote += "\n"
                    index += 1
                }
            }
        }
           
            print("----------------- :: \(newNote)-----------------")
       // }
        self.note = newNote
    }
    
    
    
    func deleteNameAmountAndNote() {
        self.reconizedTexts.removeAll()
        self.reconizedTexts = []
        self.name = ""
        self.amount = ""
        self.amountInDouble = 0.0
        self.date = ""
        self.note = ""
      //  self.requests = []
    }
    
}


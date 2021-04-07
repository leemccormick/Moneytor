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
    var reconizedTexts: [ReconizedTextScanner] = []
    var previousReconizedTexts: ReconizedTextScanner?
    var name: String = ""
    var amount: String = ""
    var amountInDouble: Double = 0.0
    var date: String = ""
    var note: String = ""
    var expenseCategory: ExpenseCategory?
    var incomeCategory: IncomeCategory?
    var hasScanned: Bool = false
    var imageScanner: UIImage?
    
    // MARK: - Helper Fuctions
        func groupingFromTheSameLine(reconizedTexts: [ReconizedTextScanner]) {
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
            var index = 0
            
            for r in sortedReconizedTexts {
               // print("-----r :: \(r.text)   \t\tMidY:: \(r.midY) \t\tMinY:: \(r.minY) \t\tMaxY:: \(r.maxY)")
                
                if index < newMidYs.count - 1 &&  index < newMinYs.count - 1 && index < newMaxYs.count - 1 {
                    
                    if newMidYs[index] == r.midY || newMinYs[index] == r.minY || newMaxYs[index] == r.maxY  {
                        newNote += "\t\t"
                        newNote += "\(r.text)"
                    } else {
                        newNote += "\n"
                        newNote += "\(r.text)"
                        index += 1
                    }
                }
            }
           // print("----------------- :: \(newNote)-----------------")
            self.note = newNote
        }
        
        func deleteNameAmountAndNote() {
            hasScanned = false
            self.reconizedTexts.removeAll()
            self.reconizedTexts = []
            self.name = ""
            self.amount = ""
            self.amountInDouble = 0.0
            self.date = ""
            self.note = ""
            self.imageScanner = nil
        }
}

// MARK: - SetupVision For ExpenseScanner
extension ScannerController {
    func detectForNameAndAmount(reconizedTexts: [ReconizedTextScanner]) {
            var potentialAmounts: [Double] = []
            for result in reconizedTexts {
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
                
                for category in ExpenseCategoryController.shared.expenseCategories {
                    print("\n=================== result ::  category \n\(result.text.lowercased().trimmingCharacters(in: .whitespaces))  ::::  \(category.nameString.lowercased().trimmingCharacters(in: .whitespaces))======================IN \(#function)\n")
                    print("\n=================== result.text.lowercased().contains(category.nameString.lowercased()):: \(result.text.lowercased().trimmingCharacters(in: .whitespaces).contains(category.nameString.lowercased().trimmingCharacters(in: .whitespaces)))======================IN \(#function)\n")
                    if result.text.lowercased().trimmingCharacters(in: .whitespaces) == (category.nameString.lowercased().trimmingCharacters(in: .whitespaces)) {
                        expenseCategory = category
                    }
                }
            }
            let str = self.name
            if str.count > 20 {
                let start = str.index(str.startIndex, offsetBy: 20)
                self.name = String(name.prefix(upTo: start))
            }
            guard let amountIsThelastInPotentialAmounts = potentialAmounts.last else {return}
            self.amountInDouble = amountIsThelastInPotentialAmounts
            self.amount = String(amountInDouble)
        print("\n===================expenseCategory :: \(expenseCategory?.nameString)======================IN \(#function)\n")
    }
        
    func setupVisionForExpenseScanner() -> [VNRequest] {
        hasScanned = true
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
        textRecognizationRequest.recognitionLanguages = ["en_US"]
        let requests = [textRecognizationRequest]
        return requests
    }
}

// MARK: - SetupVision For IncomeScanner
extension ScannerController {
    func setupVisionForIncomeScanner() -> [VNRequest] {
        hasScanned = true
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
            self.detectForNameAndAmountForIncome(reconizedTexts: self.reconizedTexts)
            self.groupingFromTheSameLine(reconizedTexts: self.reconizedTexts)
        }
        textRecognizationRequest.recognitionLevel = .accurate
        textRecognizationRequest.usesLanguageCorrection = true
        textRecognizationRequest.recognitionLanguages = ["en_US"]
        let requests = [textRecognizationRequest]
        return requests
    }
    
    func detectForNameAndAmountForIncome(reconizedTexts: [ReconizedTextScanner]) {
        var potentialAmounts: [Double] = []
        for result in reconizedTexts {
            if result.index == 0 {
                self.name += result.text
            }
            
            let rSeparates = result.text.components(separatedBy: " ")
            
            for rSeparate in rSeparates {
                if rSeparate.contains("$") {
                    var newR = rSeparate
                    newR.removeFirst()
                    let num = Double(newR)
                    if let upwrapNum = num {
                        self.amountInDouble = upwrapNum
                        print("----------------- upwrapNum contains:: \(upwrapNum)-----------------")
                    }
                } else {
                    
                    if rSeparate.isnumberordouble {
                        let num = Double(rSeparate)
                        if let upwrapNum = num {
                            if upwrapNum < 100000 {
                                potentialAmounts.append(upwrapNum)
                            }
                        }
                    }
                }
            }
            
            for category in IncomeCategoryController.shared.incomeCategories {
                print("\n=================== result ::  category \n\(result.text.lowercased().trimmingCharacters(in: .whitespaces))  ::::  \(category.nameString.lowercased().trimmingCharacters(in: .whitespaces))======================IN \(#function)\n")
                print("\n=================== result.text.lowercased().contains(category.nameString.lowercased()):: \(result.text.lowercased().trimmingCharacters(in: .whitespaces).contains(category.nameString.lowercased().trimmingCharacters(in: .whitespaces)))======================IN \(#function)\n")
                if result.text.lowercased().trimmingCharacters(in: .whitespaces) == (category.nameString.lowercased().trimmingCharacters(in: .whitespaces)) {
                    incomeCategory = category
                }
            }
        }
        let str = self.name
        if str.count > 20 {
            let start = str.index(str.startIndex, offsetBy: 20)
            self.name = String(name.prefix(upTo: start))
            print("-------------------- name: \(name) in \(#function) : ----------------------------\n)")
        }
        if amountInDouble != 0.0  {
            self.amount = String(amountInDouble)
        } else {
            guard let amountIsThelastInPotentialAmounts = potentialAmounts.last else {return}
            self.amountInDouble = amountIsThelastInPotentialAmounts
            self.amount = String(amountInDouble)
        }
    }
}


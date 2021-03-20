//
//  ExpenseScannerViewController.swift
//  Moneytor
//
//  Created by Lee McCormick on 2/22/21.
//

import UIKit
import Vision
import VisionKit

class ExpenseScannerViewController: UIViewController, VNDocumentCameraViewControllerDelegate {
    
    @IBOutlet weak var textView: UITextView!
    
    var expenseName: String?
    var expenseAmount: String = ""
    var expenseDate: String = ""
    var expenseNote: String = ""
    var note: String = ""
    
    let textRecognizationQueue = DispatchQueue.init(label: "TextRecognizationQueue", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem, target: nil)
    var requests = [VNRequest]()
    //var textRecognitionRequest = VNRecognizeTextRequest()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        
        setupVision()
    }
    
    // MARK: - Actions
    @IBAction func saveButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func scanTextButtonTapped(_ sender: Any) {
        let documentCameraController = VNDocumentCameraViewController()
        documentCameraController.delegate = self
        self.present(documentCameraController, animated: true, completion: nil)
    }
    
    func setupVision() {
        let textRecognizationRequest = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                print("No Results Found!")
                return
            }
            var recognizedText: String?
            var reconizedTextArray: [String] = []
            var indexReconizedTextArray: Int = 0
            var indexForTotal: Int?
            let maximumCandidates = 1
            for observation in observations {
                guard let candidate = observation.topCandidates(maximumCandidates).first else {continue}
                var text = candidate.string
                reconizedTextArray.append(text)
                self.note += "\(text)"
            
                
                var valueQualifier: VNRecognizedTextObservation?
                
                if let label = recognizedText {
                    if let qualifier = valueQualifier {
                        if abs(qualifier.boundingBox.minY - observation.boundingBox.minY) < 0.01 {
                            // The qualifier's baseline is within 1% of the current observation's baseline, it must belong to the current value.
                            let qualifierCandidate = qualifier.topCandidates(1)[0]
                            print("-------------------- qualifierCandidate: \(qualifierCandidate) in \(#function) : ----------------------------\n)")
                            text = qualifierCandidate.string + " " + text
                        }
                        valueQualifier = nil
                    }
                    self.expenseNote = "\(label) \t\(text)\n"
                    recognizedText = "\(label) \t\(text)\n"
                }
                
//
                
                if  text.lowercased().contains("total") || text.lowercased().contains("balance"){
        
                    self.expenseAmount = text
                    indexForTotal = indexReconizedTextArray
                    print("-----------------indexForTotal :: \(indexForTotal)-----------------")
                    print("----------------- self.expenseAmoun:: \(self.expenseAmount)-----------------")
                }
                
               /* do {
                    let types: NSTextCheckingResult.CheckingType = [.allTypes]
                    let detector = try NSDataDetector(types: types.rawValue)
                    let matches = detector.matches(in: text, options: .init(), range: NSRange(location: 0, length: text.count))
                    if !matches.isEmpty {
                        self.expenseDate = text
                    } else {
                        valueQualifier = observation
                    }
                } catch {
                    print("\n==== ERROR IN \(#function) : \(error.localizedDescription) : \(error) ====\n")
                }
                */
                
                
                
                
                do {
                    let types: NSTextCheckingResult.CheckingType = [.date]
                    let detector = try NSDataDetector(types: types.rawValue)
                    let matches = detector.matches(in: text, options: .init(), range: NSRange(location: 0, length: text.count))
                    if !matches.isEmpty {
                        self.expenseDate = text
                    } else {
                        valueQualifier = observation
                    }
                } catch {
                    print("\n==== ERROR IN \(#function) : \(error.localizedDescription) : \(error) ====\n")
                }
                indexReconizedTextArray += 1
            }
           
            
            self.expenseName = reconizedTextArray.first ?? "" + reconizedTextArray[1] + reconizedTextArray[2]
            if let index = indexForTotal {
                if reconizedTextArray.count-1 > index + 1 {
                self.expenseAmount = reconizedTextArray[index+1]
                }
            }
          
            self.textView.text = "Note: \(self.note)=========\n Expense Note :: \(self.expenseNote) \n============\n \n=======Name :::\(self.expenseName ?? "")========== \n=======Amount::: \(self.expenseAmount)========== \n=======Date\(self.expenseDate )==========)"
            
            
            print("----------------- self.expenseAmoun:: \(self.expenseAmount)-----------------")
            var costArray: [Double] = []
            for r in reconizedTextArray {
                print("\n==================reconizedTextArray :: \(r)-=======================")
                let num = Double(r)
                if let upwrapNum = num {
                    costArray.append(upwrapNum)
                }
            }
            
            print("----------------- costArray :: \(costArray)-----------------")
            
            
            
        }
        textRecognizationRequest.recognitionLevel = .accurate
        textRecognizationRequest.usesLanguageCorrection = true
        requests = [textRecognizationRequest]
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            controller.dismiss(animated: true, completion: nil)
            
            for i in 0..<scan.pageCount {
                
                let scannedImage = scan.imageOfPage(at: i)
                if let cgImage = scannedImage.cgImage {
                    let requestHandler = VNImageRequestHandler.init(cgImage: cgImage, options: [:])
                    do {
                        try requestHandler.perform(self.requests)
                        print("-----------------EXPENSE NAME FROM SCANING IS :: \(scan.title)-----------------")
                        
                    } catch {
                        print(error.localizedDescription)
                    }
                    
                }
            }
            expenseName = scan.title
            //print("-----------------EXPENSE NAME FROM SCANING IS :: \(scan.dictionaryWithValues(forKeys: ["total",scan.title]))-----------------")
        }
        
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            controller.dismiss(animated: true, completion: nil)
        }
        
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            print("\n==== ERROR SCANNING RECEIPE IN \(#function) : \(error.localizedDescription) : \(error) ====\n")
            presentAlertToUser(titleAlert: "ERROR! SCANNING RECEIPT!", messageAlert: "Please, make sure if you are using camera propertly to scan receipt!")
            controller.dismiss(animated: true, completion: nil)
        }
    }

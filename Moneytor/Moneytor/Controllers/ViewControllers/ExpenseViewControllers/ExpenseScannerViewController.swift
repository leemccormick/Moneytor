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
    
    var expenseFromScanner: Expense?
    
//    var expenseName: String?
//    var expenseAmount: String = ""
//    var expenseDate: String = ""
//    var expenseNote: String = ""
//    var note: String = ""
    
    let textRecognizationQueue = DispatchQueue.init(label: "TextRecognizationQueue", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem, target: nil)
    var requests = [VNRequest]()
    //var textRecognitionRequest = VNRecognizeTextRequest()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        print(ScannerController.shared.reconizedTexts)
       // self.requests = ScannerController.shared.setupVision()
        //ScannerController.shared.setupVision()
        //setupVision()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       // self.textView.text = ""
        self.requests = ScannerController.shared.setupVision()
      //  createExpenseFromScanner()
//        let expenseName = ScannerController.shared.name
//        let expenseAmount = ScannerController.shared.amountInDouble
//        let expenseAmountInStr = ScannerController.shared.amount
//        let expenseDate = ScannerController.shared.date
//        let expenseNote = ScannerController.shared.note
//
////        self.expenseFromScanner?.name = expenseName
////        self.expenseFromScanner?.amount = expenseAmountInStr
////        self.expenseFromScanner?.date = expenseDate
//       // var note: String = ""
//        self.textView.text = "\n Expense Note :: \(expenseNote) \n============\n \n=======Name :::\(expenseName)========== \n=======Amount::: \(expenseAmount)========== \n=======Date\(expenseDate )========== \n==================================\n)"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ScannerController.shared.deleteNameAmountAndNote()
        self.textView.text = ""
        
    }
    
//    func createExpenseFromScanner() {
//        let expenseName = ScannerController.shared.name
//        let expenseAmount = ScannerController.shared.amountInDouble
//        let expenseAmountInStr = ScannerController.shared.amount
//        let expenseDate = ScannerController.shared.date.toDate()
//        let expenseNote = ScannerController.shared.note
//        let newExpense = ExpenseController.shared.createExpenseFromScannerWith(name: expenseName, amount: expenseAmount, category: ExpenseCategoryController.shared.expenseCategories[0], date: expenseDate ?? Date(), note: <#String#>)
//        self.expenseFromScanner = newExpense
//        self.textView.text = "\n Expense Note :: \(expenseNote) \n============\n \n=======Name :::\(expenseName)========== \n=======Amount::: \(expenseAmount)========== \n=======Date\(expenseDate)========== \n==================================\n)"
//        // GO TO CityDataViewController By CODING STORYBOARD.ID
//        let storyboard = UIStoryboard(name: "Main", bundle: nil) // HAVE TO MATCH The NAME of Storyboard, this case Main.storyboard. Mostly! Strict with main.
//        let expenseDetailVC = storyboard.instantiateViewController(identifier: "expenseDetailVCStoryBoard") //HAVE TO match the Storyboard ID in storyboard
//        // The style of presenting
//       // expensesDetailVC.modalPresentationStyle = .pageSheet //You can choose the style of presenting
//
//        // Now Presenting the next VC
//        self.present(expenseDetailVC, animated: true, completion: nil)
//    }
//
    
    // MARK: - Actions
    @IBAction func saveButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func scanTextButtonTapped(_ sender: Any) {
        self.textView.text = ""
        ScannerController.shared.deleteNameAmountAndNote()

        let documentCameraController = VNDocumentCameraViewController()
        documentCameraController.delegate = self
        self.present(documentCameraController, animated: true, completion: nil)
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
        navigationController?.popViewController(animated: true)
       // expenseName = scan.title
        //print("-----------------EXPENSE NAME FROM SCANING IS :: \(scan.dictionaryWithValues(forKeys: ["total",scan.title]))-----------------")
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        presentAlertToUser(titleAlert: "CANCEL! RECEIPT SCANNER!", messageAlert: "")
        controller.dismiss(animated: true, completion: nil)
        navigationController?.popViewController(animated: true)

    }
    
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        print("\n==== ERROR SCANNING RECEIPE IN \(#function) : \(error.localizedDescription) : \(error) ====\n")
        presentAlertToUser(titleAlert: "ERROR! SCANNING RECEIPT!", messageAlert: "Please, make sure if you are using camera propertly to scan receipt!")
        controller.dismiss(animated: true, completion: nil)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationVC = segue.destination as? ExpenseDetailTableViewController else {return}
        let expense = self.expenseFromScanner
        destinationVC.expense = expense
    }
}

/*
func setupVision() {
        let textRecognizationRequest = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                print("No Results Found!")
                return
            }
            var currLabel: String = ""
            var reconizedTextArray: [String] = []
            var indexReconizedTextArray: Int = 0
            var indexForTotal: Int?
            let maximumCandidates = 1
            var valueQualifier: VNRecognizedTextObservation?
            for observation in observations {
                guard let candidate = observation.topCandidates(maximumCandidates).first else {continue}
                var text = candidate.string
                reconizedTextArray.append(text)
                self.note += "\n \(text) ==X:\(observation.boundingBox.minX) ==MidX:\(observation.boundingBox.midX) ==MaxX:\(observation.boundingBox.maxX) ==Y:\(observation.boundingBox.minY.rounded(.toNearestOrAwayFromZero)) ==MidY:\(observation.boundingBox.midY) ==MaxY:\(observation.boundingBox.maxY)\n"
                self.note += "\n"
                
              
                if let qualifier = valueQualifier {
                   // print("-----------------qualifier.boundingBox.minY :: \(qualifier.boundingBox.minY)-----------------")
                   // print("----------------- observation.boundingBox.minY:: \(observation.boundingBox.minY)-----------------")
                    
                    let dQualifier = Double(qualifier.boundingBox.midY)
                    let dObservation = Double(observation.boundingBox.midY)
                  //  print("----------------- dQualifier:: \(dQualifier.round(to: 2))-----------------")
                   // print("----------------- dObservation:: \(dObservation.round(to: 2))-----------------")
                    
                    if dQualifier.round(to: 2) == dObservation.round(to: 2) {
                        print("\(currLabel) \t\t:: \(text)")
                    } else {
                       // print("----------------- NOT THE SAME LINE-----------------")
                    }
                
                    }
            
                /*
                var valueQualifier: VNRecognizedTextObservation?
                
                if let label = recognizedText {
                    if let qualifier = valueQualifier {
                        if abs(qualifier.boundingBox.minY) ==  abs(observation.boundingBox.minY) {
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
                */
                //
                
                if  text.lowercased().contains("total") || text.lowercased().contains("balance"){
                    
                    self.expenseAmount = text
                    indexForTotal = indexReconizedTextArray
                   // print("-----------------indexForTotal :: \(indexForTotal)-----------------")
                    //print("----------------- self.expenseAmoun:: \(self.expenseAmount)-----------------")
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
                currLabel = text
                indexReconizedTextArray += 1
            }
            
            
            self.expenseName = reconizedTextArray.first ?? "" + reconizedTextArray[1] + reconizedTextArray[2]
//            if let index = indexForTotal {
//                if reconizedTextArray.count-1 > index + 1 {
//                    self.expenseAmount = reconizedTextArray[index+1]
//                }
//            }
            
          
            
            
           // print("----------------- self.expenseAmoun:: \(self.expenseAmount)-----------------")
            var costArray: [Double] = []
            for r in reconizedTextArray {
               // print("\n==================reconizedTextArray :: \(r)-=======================")
                let rSeparates = r.components(separatedBy: " ")
                for rSeparate in rSeparates {
                    
                    if rSeparate.isnumberordouble {
                        let num = Double(rSeparate)
                        if let upwrapNum = num {
                            if upwrapNum < 1000 {
                            costArray.append(upwrapNum)
                            }
                        }
                    }
                    
                    if rSeparate.contains("$") {
                        var newR = rSeparate
                        newR.removeFirst()
                        let num = Double(newR)
                        if let upwrapNum = num {
                            costArray.append(upwrapNum)
                        }
                    }
                   // print("--------------------------------------------------")
                    
                }
            }
            
        //    print("----------------- costArray :: \(costArray)-----------------")
            
            print("----------------- costArray :: \(costArray.last)-----------------")
            let expenseAmountText = String(costArray.last ?? 0.0)
            
            self.expenseAmount = expenseAmountText

            self.textView.text = "Note: \(self.note)=========\n Expense Note :: \(self.expenseNote) \n============\n \n=======Name :::\(self.expenseName ?? "")========== \n=======Amount::: \(self.expenseAmount)========== \n=======Date\(self.expenseDate )========== \n==================================\n)"
        }
        textRecognizationRequest.recognitionLevel = .accurate
        textRecognizationRequest.usesLanguageCorrection = true
        requests = [textRecognizationRequest]
    }
*/

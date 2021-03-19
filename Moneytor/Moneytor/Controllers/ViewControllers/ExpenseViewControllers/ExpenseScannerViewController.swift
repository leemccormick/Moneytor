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
    
    let textRecognizationQueue = DispatchQueue.init(label: "TextRecognizationQueue", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem, target: nil)
    var requests = [VNRequest]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            var recognizedText = ""
            let maximumCandidates = 1
            for observation in observations {
                let candidate = observation.topCandidates(maximumCandidates).first
                recognizedText += candidate?.string ?? ""
                print("----------------- recognizedText:: \(recognizedText)-----------------")
            }
            self
                .textView.text = recognizedText
        }
        textRecognizationRequest.recognitionLevel = .accurate
        self.requests = [textRecognizationRequest]
    }
    
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        controller.dismiss(animated: true, completion: nil)
        for i in 0..<scan.pageCount {
            let scannedImage = scan.imageOfPage(at: i)
            if let cgImage = scannedImage.cgImage {
                let requestHandler = VNImageRequestHandler.init(cgImage: cgImage, options: [:])
                do {
                    try requestHandler.perform(self.requests)
                } catch {
                    print(error.localizedDescription)
                }
                
            }
        }
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        //
    }
}

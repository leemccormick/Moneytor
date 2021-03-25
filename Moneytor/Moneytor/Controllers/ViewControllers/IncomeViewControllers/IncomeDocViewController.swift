//
//  IncomeDocViewController.swift
//  Moneytor
//
//  Created by Lee McCormick on 3/25/21.
//

import UIKit

class IncomeDocViewController: UIViewController {

    @IBOutlet weak var incomeDocImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViewsWithAnitamateImages()
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Methods
    func updateViewsWithAnitamateImages() {
        let images: [UIImage] = [#imageLiteral(resourceName: "checkSpilt"), #imageLiteral(resourceName: "allChecks"), #imageLiteral(resourceName: "check1"),#imageLiteral(resourceName: "check2")]
        incomeDocImageView.image = UIImage.animatedImage(with: images, duration: 13)
    }
 

}

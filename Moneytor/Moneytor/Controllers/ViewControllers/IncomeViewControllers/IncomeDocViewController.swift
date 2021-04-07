//
//  IncomeDocViewController.swift
//  Moneytor
//
//  Created by Lee McCormick on 3/25/21.
//

import UIKit

class IncomeDocViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var incomeDocImageView: UIImageView!
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViewsWithAnitamateImages()
    }
    
    // MARK: - Actions
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Methods
    func updateViewsWithAnitamateImages() {
        let images: [UIImage] = [#imageLiteral(resourceName: "m1"), #imageLiteral(resourceName: "m2"), #imageLiteral(resourceName: "m3"),#imageLiteral(resourceName: "m4")]
        incomeDocImageView.image = UIImage.animatedImage(with: images, duration: 13)
    }
}

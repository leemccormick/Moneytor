//
//  ExpenseDocViewController.swift
//  Moneytor
//
//  Created by Lee McCormick on 3/25/21.
//

import UIKit

class ExpenseDocViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var exampleReceiptsImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViewsWithAnitamateImages()
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Methods
    func updateViewsWithAnitamateImages() {
        let images: [UIImage] = [#imageLiteral(resourceName: "e0"), #imageLiteral(resourceName: "e2"), #imageLiteral(resourceName: "e3"),#imageLiteral(resourceName: "e1")]
        exampleReceiptsImageView.image = UIImage.animatedImage(with: images, duration: 13)
    }
}

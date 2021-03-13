//
//  UIViewController+Extension.swift
//  Moneytor
//
//  Created by Lee McCormick on 2/23/21.
//

import UIKit

extension UIViewController {
    
    func presentAlertToUser(titleAlert: String, messageAlert: String) {
        let alertController = UIAlertController(title: titleAlert, message: messageAlert, preferredStyle: .actionSheet)
        let dismissAction = UIAlertAction(title: "Ok", style: .cancel)
        alertController.addAction(dismissAction)
        present(alertController, animated: true)
    }
}
//
//extension UITableView  {
//    
//    func updateFooter(total: Double, tableView: UITextView) {
//        let footer = tableView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40))
//        footer.backgroundColor = .mtLightYellow
//        
//        let lable = UILabel(frame:footer.bounds)
//        let totalString = AmountFormatter.currencyInString(num: total)
//        lable.text = "TOTAL INCOMES : \(totalString)  "
//        lable.textAlignment = .center
//        lable.textColor = .mtTextDarkBrown
//        lable.font = UIFont(name: FontNames.textMoneytorGoodLetter, size: 25)
//        footer.addSubview(lable)
//        self.tableFooterView = footer
//    }
//}

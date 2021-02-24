//
//  UIViewController+Extension.swift
//  Moneytor
//
//  Created by Lee McCormick on 2/23/21.
//

import UIKit

extension UIViewController {
    func presentErrorToUser(titleAlert: String, messageAlert: String) {
        let alertController = UIAlertController(title: "ERROR! " + titleAlert, message: messageAlert, preferredStyle: .actionSheet)
        let dismissAction = UIAlertAction(title: "Ok", style: .cancel)
        alertController.addAction(dismissAction)
        present(alertController, animated: true)
    }
}

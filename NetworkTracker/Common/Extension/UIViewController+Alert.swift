//
//  UIViewController+Alert.swift
//  NetworkTracker
//
//  Created by Volodymyr Pysarenko on 15.07.2024.
//

import UIKit

extension UIViewController {
    func showWarning(title: String, body: String, then: (()->Void)? = nil) {
        DispatchQueue.main.async {
            
            let alertController:UIAlertController = UIAlertController(title: title, message: body,
                                                                      preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action:UIAlertAction!) -> Void in
                then?()
            }))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func showAlertWithAction(title: String, body: String, actionButtonTitle: String, then: (()->Void)? = nil, actionBlock: (()->Void)? = nil) {
        DispatchQueue.main.async {
            
            let alertController:UIAlertController = UIAlertController(title: title, message: body,
                                                                      preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: { (action:UIAlertAction!) -> Void in
                then?()
            }))
            alertController.addAction(UIAlertAction(title: actionButtonTitle, style: UIAlertAction.Style.default, handler: { (action:UIAlertAction!) -> Void in
                actionBlock?()
            }))
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

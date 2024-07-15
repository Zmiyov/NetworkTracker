//
//  UIViewController+Alert.swift
//  NetworkTracker
//
//  Created by Volodymyr Pysarenko on 15.07.2024.
//

import UIKit

extension UIViewController {
    func showWarning(title:String, body:String, then:(()->Void)? = nil) {
        DispatchQueue.main.async {
            
            let alertController:UIAlertController = UIAlertController(title: title, message: body,
                                                                      preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action:UIAlertAction!) -> Void in
                then?()
            }))
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

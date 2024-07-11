//
//  UIView+Shadow.swift
//  NetworkTracker
//
//  Created by Volodymyr Pysarenko on 11.07.2024.
//

import UIKit

extension UIView {
    func drawShadow() {
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.35
        self.layer.shadowRadius = 5
        self.layer.shadowOffset = .zero
    }
}

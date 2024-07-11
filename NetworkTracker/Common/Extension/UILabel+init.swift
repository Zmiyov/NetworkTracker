//
//  UILabel+init.swift
//  NetworkTracker
//
//  Created by Volodymyr Pysarenko on 11.07.2024.
//

import UIKit

extension UILabel {
    convenience init(font: UIFont?, alighment: NSTextAlignment = .left, color: UIColor = .black) {
        self.init()
        self.font = font
        self.textAlignment = alighment
        self.textColor = color
        self.adjustsFontSizeToFitWidth = false
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}

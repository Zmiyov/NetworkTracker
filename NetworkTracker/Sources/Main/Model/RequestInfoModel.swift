//
//  RequestInfoModel.swift
//  NetworkTracker
//
//  Created by Volodymyr Pysarenko on 11.07.2024.
//

import Foundation

struct RequestInfoModel: Hashable {
    let id: String
    let text: String
    let date: String
    let url: String?
}

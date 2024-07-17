//
//  RequestInfoModel.swift
//  NetworkTracker
//
//  Created by Volodymyr Pysarenko on 11.07.2024.
//

import Foundation

/// Model of data that is displayed in app
/// - Parameters:
///   - id: UUID value in string format
///   - text: Full request in String format
///   - date: Date and time when request is recieved
///   - url: Link to request site
struct RequestInfoModel: Hashable {
    let id: String
    let text: String
    let date: String
    let url: String?
}

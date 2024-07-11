//
//  MainViewModel.swift
//  NetworkTracker
//
//  Created by Volodymyr Pysarenko on 11.07.2024.
//


import Foundation
import Combine

protocol MainScreenViewModelProtocol {
    var items: PassthroughSubject<[QueryInfoModel], Error> { get }
    
    func fetchItems()
}

final class MainScreenViewModel: MainScreenViewModelProtocol, ObservableObject {
    private let mockData = [QueryInfoModel(text: "Query test", date: "March", url: "google.com"), 
                            QueryInfoModel(text: "Query test", date: "June", url: "google.com")]
    
    let items = PassthroughSubject<[QueryInfoModel], Error>()

    init() {}
    
    func fetchItems() {
        items.send(mockData)
    }
}

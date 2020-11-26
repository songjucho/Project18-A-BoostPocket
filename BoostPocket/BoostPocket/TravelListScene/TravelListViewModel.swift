//
//  TravleListViewModel.swift
//  BoostPocket
//
//  Created by sihyung you on 2020/11/24.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import Foundation

protocol TravelListPresentable {
    var travels: [TravelItemViewModel] { get }
    func createCountryListViewModel() -> CountryListViewModel?
    var didFetch: (([TravelItemViewModel]) -> Void)? { get set }

    func needFetchItems()
    @discardableResult func createTravel(countryName: String) -> TravelItemViewModel?
    func cellForItemAt(path: IndexPath) -> TravelItemViewModel?
    func numberOfItem() -> Int
}

class TravelListViewModel: TravelListPresentable {
    
    var travels: [TravelItemViewModel] = []
    var didFetch: (([TravelItemViewModel]) -> Void)?
    private weak var countryProvider: CountryProvidable?
    private weak var travelProvider: TravelProvidable?
    
    init(countryProvider: CountryProvidable?, travelProvider: TravelProvidable?) {
        self.countryProvider = countryProvider
        self.travelProvider = travelProvider
    }
    
    func needFetchItems() {
    }
    
    func createTravel(countryName: String) -> TravelItemViewModel? {
        return nil
    }
    
    func cellForItemAt(path: IndexPath) -> TravelItemViewModel? {
        return nil
    }
    
    func numberOfItem() -> Int {
        return 0
    }
    
}

extension TravelListViewModel {
    func createCountryListViewModel() -> CountryListViewModel? {
        guard let countryProvider = countryProvider else { return nil }
        return CountryListViewModel(countryProvider: countryProvider)
    }
}
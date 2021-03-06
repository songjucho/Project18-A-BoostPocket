//
//  TravelViewModelTests.swift
//  BoostPocketTests
//
//  Created by 송주 on 2020/11/25.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import XCTest
@testable import BoostPocket

class TravelViewModelTests: XCTestCase {
    
    var travelListViewModel: TravelListPresentable!
    var persistenceManager: PersistenceManagable!
    var countryProvider: CountryProvidable!
    var travelProvider: TravelProvidable!
    var country: Country!
    
    let id = UUID()
    let title = "test title"
    let memo = "memo"
    let exchangeRate = 12.1
    let budget = 3.29
    let coverImage = Data()
    let startDate = Date()
    let endDate = Date()
    let countryName = "대한민국"
    
    override func setUpWithError() throws {
        persistenceManager = PersistenceManagerStub()
        countryProvider = CountryProvider(persistenceManager: persistenceManager)
        country = countryProvider.createCountry(name: countryName, lastUpdated: Date(), flagImage: Data(), exchangeRate: 3.29, currencyCode: "KRW")
        travelProvider = TravelProvider(persistenceManager: persistenceManager)
        travelListViewModel = TravelListViewModel(countryProvider: countryProvider, travelProvider: travelProvider)
    }
    
    override func tearDownWithError() throws {
        travelListViewModel = nil
        travelProvider = nil
        country = nil
        countryProvider = nil
        persistenceManager = nil
    }
    
    func test_travelItemViewModel_createInstance() throws {
        let travel = TravelStub(id: id, title: title, memo: memo, exchangeRate: exchangeRate,
                                budget: budget, coverImage: coverImage, startDate: startDate,
                                endDate: endDate, country: country)
        let travelItemViewModel = TravelItemViewModel(travel: travel)
        
        XCTAssertNotNil(travel)
        XCTAssertEqual(travelItemViewModel.id, id)
        XCTAssertEqual(travelItemViewModel.title, title)
        XCTAssertEqual(travelItemViewModel.memo, memo)
        XCTAssertEqual(travelItemViewModel.exchangeRate, exchangeRate)
        XCTAssertEqual(travelItemViewModel.budget, budget)
        XCTAssertEqual(travelItemViewModel.coverImage, coverImage)
        XCTAssertEqual(travelItemViewModel.startDate, startDate)
        XCTAssertEqual(travelItemViewModel.endDate, endDate)
        XCTAssertEqual(travelItemViewModel.currencyCode, country?.currencyCode)
        XCTAssertEqual(travelItemViewModel.flagImage, country?.flagImage)
        XCTAssertEqual(travelItemViewModel.countryName, country?.name)
    }
    
    func test_travelListViewModel_createTravel() {
        let createdTravel = travelListViewModel.createTravel(countryName: countryName)
        
        XCTAssertNotNil(createdTravel)
        XCTAssertEqual(createdTravel, travelListViewModel.travels.first)
        
        XCTAssertEqual(createdTravel?.title, country?.name)
        XCTAssertEqual(createdTravel?.countryName, country?.name)
        XCTAssertEqual(createdTravel?.currencyCode, country?.currencyCode)
        XCTAssertEqual(createdTravel?.exchangeRate, country?.exchangeRate)
        XCTAssertEqual(createdTravel?.budget, 0.0)
        XCTAssertNotNil(createdTravel?.endDate)
        XCTAssertNotNil(createdTravel?.startDate)
        XCTAssertNotNil(createdTravel?.coverImage)
        XCTAssertNotNil(createdTravel?.flagImage)
    }
    
    func test_travelListViewModel_needFetchItems() {
        XCTAssertNotNil(countryProvider.createCountry(name: "미국", lastUpdated: Date(), flagImage: Data(), exchangeRate: 3.29, currencyCode: "USD"))
        XCTAssertNotNil(countryProvider.createCountry(name: "일본", lastUpdated: Date(), flagImage: Data(), exchangeRate: 12.1, currencyCode: "JPY"))
        
        XCTAssertNotNil(travelProvider.createTravel(countryName: "대한민국"))
        XCTAssertNotNil(travelProvider.createTravel(countryName: "미국"))
        XCTAssertNotNil(travelProvider.createTravel(countryName: "일본"))
        
        travelListViewModel.needFetchItems()
        XCTAssertEqual(travelListViewModel.travels.count, 3)
        XCTAssertEqual(travelListViewModel.travels.first?.title, "대한민국")
        XCTAssertEqual(travelListViewModel.travels.last?.title, "일본")
    }
    
    func test_travelListViewModel_cellForItemAt() {
        travelListViewModel.createTravel(countryName: countryName)

        let travelItem = travelListViewModel.cellForItemAt(path: IndexPath(row: 0, section: 0))

        XCTAssertEqual(travelItem?.title, country?.name)
        XCTAssertEqual(travelItem?.countryName, country?.name)
        XCTAssertEqual(travelItem?.currencyCode, country?.currencyCode)
        XCTAssertEqual(travelItem?.exchangeRate, country?.exchangeRate)
    }
    
    func test_travelListViewModel_numberOfItem() {
        XCTAssertNotNil(countryProvider.createCountry(name: "미국", lastUpdated: Date(), flagImage: Data(), exchangeRate: 3.29, currencyCode: "USD"))
        XCTAssertNotNil(countryProvider.createCountry(name: "일본", lastUpdated: Date(), flagImage: Data(), exchangeRate: 12.1, currencyCode: "JPY"))

        travelListViewModel.createTravel(countryName: "대한민국")
        travelListViewModel.createTravel(countryName: "미국")
        travelListViewModel.createTravel(countryName: "가나") // 없는 국가 -> 여행생성실패
        
        XCTAssertEqual(travelListViewModel.numberOfItem(), 2) // 그러므로 대한민국,미국 2개여야한다
    }
    
    func test_travelListViewModel_deleteTravel() {
        let createdTravel = travelListViewModel.createTravel(countryName: "대한민국")
        let travelId = createdTravel?.id
        XCTAssertNotNil(createdTravel)
        XCTAssertNotNil(travelId)
        XCTAssertTrue(travelListViewModel.deleteTravel(id: travelId ?? UUID()))
    }
}

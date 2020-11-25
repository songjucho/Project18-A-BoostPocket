//
//  PersistenceManager.swift
//  BoostPocket
//
//  Created by sihyung you on 2020/11/23.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

import Foundation
import CoreData

protocol PersistenceManagable: AnyObject {
    var modelName: String { get }
    var persistentContainer: NSPersistentContainer { get }
    var context: NSManagedObjectContext { get }
    func fetchAll<T: NSManagedObject>(request: NSFetchRequest<T>) -> [T]
    func fetch(_ request: NSFetchRequest<NSFetchRequestResult>) -> [Any]?
    func count<T: NSManagedObject>(request: NSFetchRequest<T>) -> Int?
    @discardableResult func createObject(newObjectInfo: InformationProtocol) -> DataModelProtocol?
    @discardableResult func saveContext() -> Bool
    @discardableResult func delete(object: DataModelProtocol) -> Bool
}

class PersistenceManager: PersistenceManagable {
    
    private(set) var modelName = "BoostPocket"
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: modelName)
        container.loadPersistentStores { (_, error) in
            if let error = error as NSError? {
                dump(error)
            }
        }
        
        return container
    }()
    
    var context: NSManagedObjectContext {
        return self.persistentContainer.viewContext
    }
    
    // MARK: - Core Data Saving support
    
    @discardableResult
    func saveContext() -> Bool {
        if context.hasChanges {
            do {
                try context.save()
                return true
            } catch {
                let nserror = error as NSError
                print(nserror.localizedDescription)
                return false
            }
        }
        
        return false // 주의
    }
    
    // MARK: - Core Data Creating support
    
    @discardableResult
    func createObject(newObjectInfo: InformationProtocol) -> DataModelProtocol? {
        
        var createdObject: DataModelProtocol?
        
        switch newObjectInfo.entityType {
        case .countryType:
            guard let newObjectInfo = newObjectInfo as? CountryInfo else { return nil }
            createdObject = setupCountryInfo(countryInfo: newObjectInfo)
            
        case .travelType:
            guard let newObjectInfo = newObjectInfo as? TravelInfo else { return nil }
            createdObject = setupTravelInfo(travelInfo: newObjectInfo)
            
        case .historyType:
            return nil
        }
        
        do {
            try self.context.save()
            return createdObject
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    private func setupCountryInfo(countryInfo: CountryInfo) -> Country? {
        guard let entity = NSEntityDescription.entity(forEntityName: Country.entityName, in: self.context) else { return nil }
        let newCountry = Country(entity: entity, insertInto: context)
        
        newCountry.name = countryInfo.name
        newCountry.lastUpdated = countryInfo.lastUpdated
        newCountry.flagImage = countryInfo.flagImage
        newCountry.exchangeRate = countryInfo.exchangeRate
        newCountry.currencyCode = countryInfo.currencyCode
        
        return newCountry
    }
    
    private func setupTravelInfo(travelInfo: TravelInfo) -> Travel? {
        guard let entity = NSEntityDescription.entity(forEntityName: Travel.entityName, in: self.context) else { return nil }
        let newTravel = Travel(entity: entity, insertInto: context)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Country.entityName)
        fetchRequest.predicate = NSPredicate(format: "name == %@", travelInfo.countryName)
        
        guard let countries = fetch(fetchRequest) as? [Country],
            let fetchedCountry = countries.first
            else { return nil }
        
        newTravel.title = fetchedCountry.name
        newTravel.exchangeRate = fetchedCountry.exchangeRate
        newTravel.country = fetchedCountry
        newTravel.id = UUID()
        newTravel.coverImage = Data() // TODO: - asset에 디폴트 이미지 넣어놓기
        
        return newTravel
    }
    
    // MARK: - Core Data Fetching support
    
    // TODO: - 테스트코드 작성하기
    func fetchAll<T: NSManagedObject>(request: NSFetchRequest<T>) -> [T] {
        if T.self == Country.self {
            let nameSort = NSSortDescriptor(key: "name", ascending: true)
            request.sortDescriptors = [nameSort]
        }
        
        do {
            let fetchedResult = try self.context.fetch(request)
            return fetchedResult
        } catch {
            return []
        }
    }
    
    // TODO: - Seg fault 에러 알아보기
    func fetch(_ request: NSFetchRequest<NSFetchRequestResult>) -> [Any]? {
        do {
            let fetchResult = try self.context.fetch(request)
            return fetchResult
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    // MARK: - Core Data Deleting support

    @discardableResult
    func delete(object: DataModelProtocol) -> Bool {
        
        var deletingObject = NSManagedObject()
        
        if let travelObject = object as? Travel {
            deletingObject = travelObject
        } else if let countryObject = object as? Country {
            deletingObject = countryObject
        }
        
        self.context.delete(deletingObject)
        do {
            try context.save()
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    // MARK: - Core Data Counting support
    
    func count<T: NSManagedObject>(request: NSFetchRequest<T>) -> Int? {
        do {
            let count = try self.context.count(for: request)
            return count
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}

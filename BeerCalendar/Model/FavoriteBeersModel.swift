//
//  FavoriteBeersModel.swift
//  BeerCalendar
//
//  Created by Yuriy Pashkov on 8/4/21.
//

import Foundation

class FavoriteBeersModel {
    
    //static let shared = FavoriteBeersModel()
    var listOfFavoriteBeers: [Int] = []
    
    init() {
        listOfFavoriteBeers = defaults.object(forKey: "listOfFavoriteBeers") as? [Int] ?? [Int]()
    }
    
    private let defaults = UserDefaults.standard
    
    func isCurrentBeerFavorite(id: Int) -> Bool {
        for item in listOfFavoriteBeers {
            if item == id {
                return true
            }
        }
        return false
    }
    
    
    func saveBeerToFavorites(id: Int) {
        listOfFavoriteBeers.append(id)
        defaults.set(listOfFavoriteBeers, forKey: "listOfFavoriteBeers")
    }
    
    func removeBeerFromFavorites(id: Int) {
        for i in 0..<listOfFavoriteBeers.count {
            if listOfFavoriteBeers[i] == id {
                listOfFavoriteBeers.remove(at: i)
                defaults.set(listOfFavoriteBeers, forKey: "listOfFavoriteBeers")
                break
            }
        }
    }
    
}

//
//  FavoriteBeersModel.swift
//  BeerCalendar
//
//  Created by Yuriy Pashkov on 8/4/21.
//

import Foundation

class FavoriteBeersModel {

    var listOfFavoriteBeers: [String] = []
    
    init() {
        listOfFavoriteBeers = defaults.object(forKey: "listOfFavoriteBeers") as? [String] ?? [String]()
    }
    
    private let defaults = UserDefaults.standard
    
    func isCurrentBeerFavorite(id: String) -> Bool {
        for item in listOfFavoriteBeers {
            if item == id {
                return true
            }
        }
        return false
    }
    
    
    func saveBeerToFavorites(id: String) {
        listOfFavoriteBeers.append(id)
        defaults.set(listOfFavoriteBeers, forKey: "listOfFavoriteBeers")
    }
    
    func removeBeerFromFavorites(id: String) {
        for i in 0..<listOfFavoriteBeers.count {
            if listOfFavoriteBeers[i] == id {
                listOfFavoriteBeers.remove(at: i)
                defaults.set(listOfFavoriteBeers, forKey: "listOfFavoriteBeers")
                break
            }
        }
    }
    
}

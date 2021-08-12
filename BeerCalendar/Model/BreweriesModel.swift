//
//  BreweriesModel.swift
//  BeerCalendar
//
//  Created by Yuriy Pashkov on 8/10/21.
//

import Foundation

class BreweriesModel {
    
    var breweries: [BreweryData] = [BreweryData]()
    
    init(breweryData: [BreweryData]) {
        breweries = breweryData
    }
    
    func getCurrentBrewery(id: Int) -> BreweryData? {
        for brewery in breweries {
            if brewery.id == id {
                return brewery
            }
        }
        return nil
    }
}

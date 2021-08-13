//
//  CalendarModel.swift
//  BeerCalendar
//
//  Created by Yuriy Pashkov on 7/29/21.
//

import Foundation

class CalendarModel {
    
    var beers: [BeerData] = [BeerData]()
    
    var currentIndex = -1
    var borderIndex = -1
    var swipesCount = 0
    var isCrowdFindingADShow = true
    
    init(beerData: [BeerData]) {
        beers = beerData
        // здесь можно послать запрос на инфо 
    }
    
    func getTodayBeer() -> BeerData? {
        guard let currentDate = dateToString() else {return nil}
        for i in 0..<beers.count {
            let beer = beers[i]
            if currentDate == beer.beerDate {
                currentIndex = i
                borderIndex = i
                return beer
            }
        }
        return nil
    }
    
    func getPreviousBeer() -> BeerData? {
        if currentIndex > 0 {
            swipesCount += 1
            currentIndex -= 1
            return beers[currentIndex]
        }
        return nil
    }
    
    func getNextBeer() -> BeerData? {
        if currentIndex < beers.count - 1, currentIndex < borderIndex {
            swipesCount += 1
            currentIndex += 1
            return beers[currentIndex]
        }
        return nil
    }
    
    func getBeerForID(id: Int) -> BeerData? {
        for i in 0..<beers.count {
            if beers[i].id == id {
                return beers[i]
            }
        }
        return nil
    }
    
    func updateBorderIndex() {
        //borderIndex += 1
        // метод который должен увеличить borderIndex с наступлением новых суток для того, чтобы можно было перелистнуть календарь вперед
        // или настроить таймер в майнВиСи который каждые 10 секунд будет проверять наступление новой даты и при наступлении увеличивать бордерИндекс или же вообще возвращать актуальное для новой даты пиво
    }

    
    func setCurrentIndexForChoosenFavoriteBeer(beerID: Int) -> Bool {
        for i in 0..<beers.count {
            if beers[i].id == beerID {
                currentIndex = i
                return true
            }
        }
        return false
    }
    
    func getListOfFavoritesBeers(listOfBeersID: [Int]) -> [BeerData] {
        var resultArray = [BeerData]()
        for id in listOfBeersID {
            for beer in beers {
                if beer.id == id {
                    resultArray.append(beer)
                    break
                }
            }
        }
        return resultArray
    }
    
    func haveOneDayBetweenTwoBeers(firstBeer: BeerData, secondBeer: BeerData) -> Bool {
        if let firstDateArray = firstBeer.getIntDate(), let secondDateArray = secondBeer.getIntDate() {
            guard firstDateArray[1] == secondDateArray[1] else { return false }
            if firstDateArray[0] - secondDateArray[0] == 1 {
                return true
            } else {
                return false
            }
        }
        return false
    }
    
    private func dateToString() -> String? {
        let calendar = Calendar.current
        let currentDate = Date()
        let dateComponents = calendar.dateComponents([.day, .month, .year], from: currentDate)
        if let day = dateComponents.day, let month = dateComponents.month, let year = dateComponents.year {
            return "\(day).\(month).\(year)"
        }
        return nil
    }
    
    func showCrowdFinding() -> Bool {
        guard isCrowdFindingADShow else {return false}
        if swipesCount > 5 {
            swipesCount = 0
            return true
        }
        return false
    }
    
}

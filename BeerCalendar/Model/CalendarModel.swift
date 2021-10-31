//
//  CalendarModel.swift
//  BeerCalendar
//
//  Created by Yuriy Pashkov on 7/29/21.
//

import Foundation
import Kingfisher

class CalendarModel {
    
    var beers: [BeerData] = [BeerData]()
    
    var currentIndex = -1
    static var borderIndex = -1
    var swipesCount = 0
    var isCrowdFindingADShow = false // по дефолту не показываем рекламный VC
    var crowdFindingData: CrowdFindingADData?
    
    init(beerData: [BeerData]) {
        beers = beerData.sorted(by: { $0.date.compare($1.date) == .orderedAscending}) // сортируем массив пив по дате 
        // здесь можно послать запрос на инфо по краудфандингу
        NetworkService.shared.requestCrowdFindingData { result in
            switch result {
            case .success(let resultData):
                if let showing = resultData.isADShow, let urlString = resultData.imgUrl, showing { // если нет картинки на сервере - здесь беда
                    self.crowdFindingData = resultData
                    self.isCrowdFindingADShow = showing
                    self.downloadImage(urlString: urlString)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    
    func getTodayBeer() -> BeerData? {
        guard let currentDate = dateToString() else {return nil}
        for i in 0..<beers.count {
            let beer = beers[i]
            if currentDate == beer.beerDate {
                currentIndex = i
                CalendarModel.borderIndex = i
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
        if currentIndex < beers.count - 1, currentIndex < CalendarModel.borderIndex {
            swipesCount += 1
            currentIndex += 1
            return beers[currentIndex]
        }
        return nil
    }
    
    func getBeerForID(id: String) -> BeerData? {
        for i in 0..<beers.count {
            if beers[i].id == id {
                return beers[i]
            }
        }
        return nil
    }
    
    func getBeerForDate(date: String) -> BeerData? {
        for i in 0..<beers.count {
            if beers[i].beerDate == date {
                return beers[i]
            }
        }
        return nil
    }
    
    func isBeerForDateExist(date: String) -> Bool {
        for beer in beers {
            if beer.beerDate == date {
                return true
            }
        }
        return false
    }
    
    func setCurrentIndexForChoosenFavoriteBeer(beerID: String) -> Bool {
        for i in 0..<beers.count {
            if beers[i].id == beerID {
                currentIndex = i
                return true
            }
        }
        return false
    }
    
    func compareTwoBeersDate(beerOne: BeerData?, beerTwo: BeerData?) -> Bool { //если дата первого пива больше - вернёт true
        guard let beerOne = beerOne, let beerTwo = beerTwo  else { return false }
        if beerOne.date.compare(beerTwo.date) == .orderedDescending {
            return true
        } else {
            return false
        }
    }
    
    func getListOfFavoritesBeers(listOfBeersID: [String]) -> [BeerData] {
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
        if swipesCount > 13 {
            swipesCount = 0
            return true
        }
        return false
    }
    
    private func downloadImage(urlString: String) {
        guard let url = URL(string: urlString) else {return}
        let resource = ImageResource(downloadURL: url)
        KingfisherManager.shared.retrieveImage(with: resource) { result in
            switch result {
            case .success:
                ()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
    }
    
}

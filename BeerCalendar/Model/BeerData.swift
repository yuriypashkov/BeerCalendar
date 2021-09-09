//
//  BeerData.swift
//  BeerCalendar
//
//  Created by Yuriy Pashkov on 7/26/21.
//

import Foundation

struct BeerData: Codable {
    
    var id: String?
    var beerDate: String?
    var beerName: String?
    var beerType: String?
    var beerABV: String?
    var beerIBU: String?
    var beerDescription: String?
    var beerLabelURL: String?
    var beerLabelPreviewURL: String?
    var untappdURL: String?
    var breweryID: Int?
    var comment: String?
    var firstColor: String?
    var secondColor: String?
    var beerSpecialInfoTitle: String?
    var beerSpecialInfo: String?
    
    var date: Date {
        if let beerDate = beerDate {
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "dd.MM.yyyy"
            if let resultDate = dateFormatterGet.date(from: beerDate) {
                return resultDate
            } else {
                return Date()
            }
        }
        return Date()
    }
    
    func getStrDate() -> [String]? {
        if let beerDate = beerDate {
            //получим из строки Date
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "dd.MM.yyyy"
            
            guard let date = dateFormatterGet.date(from: beerDate) else {return nil}
            
            //из Date получим день и название месяца в правильном падеже
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.locale = Locale(identifier: "ru_RU")
            dateFormatterPrint.dateFormat = "LLLL"
            let month = dateFormatterPrint.string(from: date)
            dateFormatterPrint.dateFormat = "d"
            let day = dateFormatterPrint.string(from: date)
            
            return [day, month.uppercased()]
        }
        return nil
    }
    
    func getStrDateForSharingImage() -> String? {
        if let beerDate = beerDate {
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "dd.MM.yyyy"
            
            guard let date = dateFormatterGet.date(from: beerDate) else {return nil}
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.locale = Locale(identifier: "ru_RU")
            dateFormatterPrint.dateFormat = "d"
            let day = dateFormatterPrint.string(from: date)
            dateFormatterPrint.dateFormat = "MMMM"
            let month = dateFormatterPrint.string(from: date)
            dateFormatterPrint.dateFormat = "yyyy"
            let year = dateFormatterPrint.string(from: date)
            return "\(day) \(month.uppercased()) \(year)"
            
        }
        return nil
    }
    
    func getIntDate() -> [Int]? {
        if let beerDate = beerDate {
            let components = beerDate.components(separatedBy: ".")
            if let day = Int(components[0]), let month = Int(components[1]) {
                return [day, month]
            }
        }
        return nil
    }
    
    
}




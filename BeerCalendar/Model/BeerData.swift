//
//  BeerData.swift
//  BeerCalendar
//
//  Created by Yuriy Pashkov on 7/26/21.
//

import Foundation

struct BeerData: Codable {
    
    var id: Int?
    var beerDate: String?
    var beerName: String?
    var beerManufacturer: String?
    var beerType: String?
    var beerABV: String?
    var beerIBU: Int?
    var beerDescription: String?
    var beerLabelURL: String?
    var beerLabelPreviewURL: String?
    var backgroundColor: String?
    var untappdURL: String?
    
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
    
    
}




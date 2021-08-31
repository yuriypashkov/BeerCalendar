//
//  DateValidator.swift
//  BeerCalendar
//
//  Created by Yuriy Pashkov on 8/30/21.
//

import Foundation

class DateValidator {
    
    static let shared = DateValidator()
    
    func isDateValid(day: Int, month: String) -> Bool {
        switch month {
        //case 1,3,5,7,8,10,12:
        case "Январь", "Март", "Май", "Июль", "Август", "Октябрь", "Декабрь":
            return day <= 31 ? true : false
        //case 4,6,9,11:
        case "Апрель","Июнь", "Сентябрь", "Ноябрь":
            return day <= 30 ? true : false
        case "Февраль":
            let calendar = Calendar.current
            let date = Date()
            let calendarComponents = calendar.dateComponents([.year], from: date)
            if let year = calendarComponents.year {
                if year % 4 == 0 {
                    return day <= 29 ? true : false
                } else {
                    return day <= 28 ? true : false
                }
            }
            return false
        default: ()
        }
        return false
    }
    
    func returnLastDayForMonth(month: String) -> Int {
        switch month {
            case "Апрель","Июнь", "Сентябрь", "Ноябрь":
                return 30
            case "Февраль":
                return 28
            default:
                return 31
        }
    }
    
}

//
//  TimerManager.swift
//  BeerCalendar
//
//  Created by Yuriy Pashkov on 8/29/21.
//

import Foundation

class TimerManager {
    
    static let shared = TimerManager()
    
    func startTimer() {
        let timeCalendar = Calendar.current
        let currentDate = Date()
        let currentDateComponents = timeCalendar.dateComponents([.day], from: currentDate)
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true, block: { timer in
            let date = Date()
            let dateComponents = timeCalendar.dateComponents([.day], from: date)
            if dateComponents.day != currentDateComponents.day {
                CalendarModel.borderIndex += 1
                timer.invalidate()
                self.startTimer()
            }
        })
    }

}

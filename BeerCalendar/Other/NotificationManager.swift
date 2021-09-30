//
//  NotificationManager.swift
//  BeerCalendar
//
//  Created by Yuriy Pashkov on 9/29/21.
//

import Foundation
import UserNotifications

class NotificationManager {
    
    static let shared = NotificationManager()
    
    private func createNotificationContent() -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Пиво дня"
        content.body = "Какое оно сегодня?"
        content.sound = UNNotificationSound.default
        //content.badge = NSNumber(value: 1)
        return content
    }
    
    func sheduleNotification() {
        let content = createNotificationContent()
        
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        dateComponents.hour = 20
        dateComponents.minute = 12
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // Create request
        let notificationIdentifier = "LocalNotification"
        let request = UNNotificationRequest(identifier: notificationIdentifier,
                    content: content, trigger: trigger)

        // Schedule request
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { (error) in
            if error != nil { print(error?.localizedDescription ?? "none") }
            print("NOTIFICATION SHEDULED")
        }
        
        
//        notificationCenter.getDeliveredNotifications { result in
//            for note in result {
//                print("NOTIFICATIO:")
//                print(note)
//            }
//        }
        
        
    }
    
}

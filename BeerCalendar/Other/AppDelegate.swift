//
//  AppDelegate.swift
//  BeerCalendar
//
//  Created by Yuriy Pashkov on 7/26/21.
//

import UIKit
import Kingfisher
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    private func requestUserPermissionForLocalNotifications() {
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { granted, error in
            guard granted else { return }
            self.notificationCenter.getNotificationSettings { settings in
                //print(settings)
                guard settings.authorizationStatus == .authorized else { return }
            }
        }
    }
    
    private func setupKingfisherSettings() {
        ImageCache.default.memoryStorage.config.totalCostLimit = 1024*1024*20 // ограничиваем KF Ram Cache до 20 mb, иначе он кеширует картинки в RAM и выжирает память при прокрутке страниц
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        setupKingfisherSettings()
        
        requestUserPermissionForLocalNotifications()
        
        NotificationManager.shared.sheduleNotification()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}


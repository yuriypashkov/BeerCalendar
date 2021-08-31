//
//  AlertManager.swift
//  BeerCalendar
//
//  Created by Yuriy Pashkov on 8/30/21.
//

import Foundation
import UIKit

class AlertManager {
    
    static let shared = AlertManager()
    
    func createAlert(title: String, text: String) -> UIAlertController {
        let alertView = UIAlertController(title: title, message: text, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Oк", style: .default, handler: nil)
        alertView.addAction(alertAction)
        return alertView
    }
    
}

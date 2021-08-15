//
//  ColorService.swift
//  BeerCalendar
//
//  Created by Yuriy Pashkov on 8/9/21.
//

import Foundation
import UIKit

class ColorService {
    
    static let shared = ColorService()
    
    func getFontColors(backgroundColor: UIColor) -> [UIColor]? {
        if let colorComponents = backgroundColor.cgColor.components {
            let r = colorComponents[0]
            let g = colorComponents[1]
            let b = colorComponents[2]
            let average = (0.299 * r + 0.587 * g + 0.114 * b)
            //print("Red: \(r), Green: \(g), Blue: \(b), Average: \(average)")
            if average  > 0.5 {
                return [UIColor.black, UIColor(hex: "#232020"), UIColor(hex: "#3f3f3f"), UIColor(hex:"#464545")] // темные шрифты для светлого фона
            } else {
                return [UIColor(hex: "#FFFAFA"), UIColor(hex: "#cec8c8"), UIColor(hex: "#d8d2d2"), UIColor(hex: "#d8d2d9")] // светлые шрифты для темного фона
            }
            
        }
        return nil
    }
    
}

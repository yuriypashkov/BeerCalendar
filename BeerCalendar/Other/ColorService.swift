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
            if average  > 0.5 {
                return [UIColor.black, UIColor(hex: "#232020"), UIColor(hex: "#3f3f3f"), UIColor(hex:"#464545")] // темные шрифты для светлого фона
            } else {
                return [UIColor(hex: "#FFFAFA"), UIColor(hex: "#FFFAFA"), UIColor(hex: "#d8d2d2"), UIColor(hex: "#d8d2d9")] // светлые шрифты для темного фона
            }
            
        }
        return nil
    }
    
    private func makeGradientLayer(_ object : UIView, startPoint : CGPoint, endPoint : CGPoint, gradientColors : [Any]) -> CAGradientLayer {
            let gradient: CAGradientLayer = CAGradientLayer()
            gradient.colors = gradientColors
            gradient.locations = [0.0 , 1.0]
            gradient.startPoint = startPoint
            gradient.endPoint = endPoint
            gradient.frame = CGRect(x: 0, y: 0, width: object.frame.size.width, height: object.frame.size.height)
            return gradient
        }
    
    func setGradientBackgroundOnView(view: UIView, firstColor: UIColor, secondColor: UIColor, cornerRadius: CGFloat) {
        let start : CGPoint = CGPoint(x: 0.5, y: 0.0)
        let end : CGPoint = CGPoint(x: 0.5, y: 1.0)
        
        let gradient: CAGradientLayer = self.makeGradientLayer(view, startPoint: start, endPoint: end, gradientColors: [firstColor.cgColor, secondColor.cgColor])
        gradient.opacity = 0.9
        gradient.name = "backgroundColor"
        gradient.cornerRadius = cornerRadius
        
        view.layer.sublayers?.forEach({ layer in
            if layer.name == "backgroundColor" {
                layer.removeFromSuperlayer()
            }
        })
        
        //view.transform = CGAffineTransform.identity
        
        view.layer.insertSublayer(gradient, at: 0)
    }
    
}

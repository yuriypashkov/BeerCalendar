//
//  Utils.swift
//  BeerCalendar
//
//  Created by Yuriy Pashkov on 7/28/21.
//

import Foundation
import UIKit
import AudioToolbox

protocol MainViewControllerDelegate {
    func goToChoosenFavoriteBeer(beer: BeerData)
}

extension UIView {
    
   func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}

extension UIDevice {
    static func vibrate() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        //AudioServicesPlaySystemSound(1520)
    }
}

extension UIColor {
    
    convenience init(hex: String) {
        
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
                var int = UInt64()
                Scanner(string: hex).scanHexInt64(&int)
                let a, r, g, b: UInt64
                switch hex.count {
                case 3: // RGB (12-bit)
                    (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
                case 6: // RGB (24-bit)
                    (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
                case 8: // ARGB (32-bit)
                    (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
                default:
                    (a, r, g, b) = (255, 0, 0, 0)
                }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255) 
    }
    
}

extension UIImageView {
    
    // метод для покраски векторных иконок
    func setImageColor(color: UIColor) { // переписать
            let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
            self.image = templateImage
            self.tintColor = color
        }
    
    func applyshadowWithCorner(containerView : UIView, cornerRadious : CGFloat){
            containerView.clipsToBounds = false
            containerView.layer.shadowColor = UIColor.black.cgColor
            containerView.layer.shadowOpacity = 1
            containerView.layer.shadowOffset = CGSize.zero
            containerView.layer.shadowRadius = 10
            containerView.layer.cornerRadius = cornerRadious
            containerView.layer.shadowPath = UIBezierPath(roundedRect: containerView.bounds, cornerRadius: cornerRadious).cgPath
            self.clipsToBounds = true
            self.layer.cornerRadius = cornerRadious
        }

}

extension UIImage {
    
    func rounded(radius: CGFloat) -> UIImage {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIBezierPath(roundedRect: rect, cornerRadius: radius).addClip()
        draw(in: rect)
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
    
    // тень под картинкой
    func addShadow(blurSize: CGFloat = 6.0) -> UIImage {

        let shadowColor = UIColor(white: 0.0, alpha: 0.5).cgColor

        let context = CGContext(data: nil,
                                width: Int(self.size.width + blurSize),
                                height: Int(self.size.height + blurSize),
                                bitsPerComponent: self.cgImage!.bitsPerComponent,
                                bytesPerRow: 0,
                                space: CGColorSpaceCreateDeviceRGB(),
                                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!

        context.setShadow(offset: CGSize(width: blurSize / 4, height: -blurSize / 4),
                          blur: blurSize,
                          color: shadowColor)

    
        context.draw(self.cgImage!,
                     in: CGRect(x: 0, y: blurSize, width: self.size.width, height: self.size.height),
                     byTiling: false)

        return UIImage(cgImage: context.makeImage()!)
    }
    
}


//Family: Okta Neue Font names: ["OktaNeue-Normal", "OktaNeue-Bold", "OktaNeue-MediumItalic", "OktaNeue-SemiBold", "OktaNeue-LightItalic", "OktaNeue-Light", "OktaNeue-Regular", "OktaNeue-Medium"]

// «Токсовский Трамплин — пиво дня 5 июля 2021, согласно пивному календарю! @Beer.Calendar #BeerCalendar *ссылка на приложение*»

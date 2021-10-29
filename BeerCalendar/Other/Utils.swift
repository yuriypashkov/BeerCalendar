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
    func goToChooseneBeer(choosenBeer: BeerData)
    func goToBeerFromDatePicker(date: String)
    func isBeerExist(date: String) -> Bool
    func showManual()
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
    
    // method from StackOverflow for calculate buttons frame.origin
    func getConvertedFrame(fromSubview subview: UIView) -> CGRect? {
        guard subview.isDescendant(of: self) else {
            return nil
        }
        
        var frame = subview.frame
        if subview.superview == nil {
            return frame
        }
        
        var superview = subview.superview
        while superview != self {
            frame = superview!.convert(frame, to: superview!.superview)
            if superview!.superview == nil {
                break
            } else {
                superview = superview!.superview
            }
        }
        
        return superview!.convert(frame, to: self)
    }
    
    // create array of coordinates
    func createArrayOfCoordinates(views: [UIView]) -> [CGRect] {
        var result: [CGRect] = []
        for view in views {
            let frame = self.getConvertedFrame(fromSubview: view)
            if let frame = frame {
                result.append(frame)
            }
        }
        return result
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

    // высплывающий арт при дабл-тапе по картинке
    func showDoubleTapArt(imageForShowing: UIImage) {
        let imageView = UIImageView(frame: CGRect(x: 3 * self.frame.size.width / 8, y: 3 * self.frame.size.height / 8, width: self.frame.size.width / 4, height: self.frame.size.height / 4))
        imageView.image = imageForShowing
        //imageView.alpha = 0.8
        //imageView.setImageColor(color: .systemRed)
        imageView.contentMode = .scaleAspectFit
        self.addSubview(imageView)
        UIView.animate(withDuration: 0.5) {
            imageView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            imageView.alpha = 0
        } completion: { finished in
            imageView.removeFromSuperview()
        }

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
    
    // тень под картинкой, нужно при отрисовке картинки для инсты
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
    
    func resized(toWidth width: CGFloat) -> UIImage? {
            let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
            UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
            defer { UIGraphicsEndImageContext() }
            draw(in: CGRect(origin: .zero, size: canvasSize))
            return UIGraphicsGetImageFromCurrentImageContext()
        }
    
}

extension UIButton {
    
    func pressedEffectForFavorite() {
        UIView.animate(withDuration: 0.2) {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        } completion: { finished in
            UIView.animate(withDuration: 0.2) {
                self.transform = CGAffineTransform.identity
            }
        }
    }
    
    func pressedEffect(scale: CGFloat, _ myCompletion: @escaping  () -> Void) {
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        } completion: { finished in
            UIView.animate(withDuration: 0.1) {
                self.transform = CGAffineTransform.identity
            } completion: { finished in
                myCompletion()
            }
        }
    }
    
}

extension NSAttributedString {
    
    convenience init?(html: String, fontName: String, fontSize: Int) {
        let str = "<style>body {font-family: '\(fontName)'; font-size: \(fontSize)px; color: #232020; } .bld { font-family: 'OktaNeue-SemiBold'} .half {line-height: 1.2em}</style>\(html)"
            guard let data = str.data(using: .unicode) else {
                return nil
        }
            try? self.init(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
        }
    

}
//text-align: justify;
//Family: Okta Neue Font names: ["OktaNeue-Normal", "OktaNeue-Bold", "OktaNeue-MediumItalic", "OktaNeue-SemiBold", "OktaNeue-LightItalic", "OktaNeue-Light", "OktaNeue-Regular", "OktaNeue-Medium"]


//
//  PictureCreator.swift
//  BeerCalendar
//
//  Created by Yuriy Pashkov on 8/17/21.
//

import Foundation
import UIKit
import Kingfisher

class PictureCreator {
    
    static let shared = PictureCreator()
    
    func createImageForInstagram(currentBeer: BeerData?, currentBrewery: BreweryData?, completion: @escaping (_ result: UIImage?, _ error: String?) -> Void) {
        let size = CGSize.init(width: 1080, height: 1920)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        if UIGraphicsGetCurrentContext() != nil {
            
            
            guard let beer = currentBeer else {
                UIGraphicsEndImageContext()
                completion(nil, "Error with currentBeer")
                return
            }
            
            // create background
            let backgroundView = UIView(frame: CGRect(origin: .zero, size: size))
            backgroundView.backgroundColor = .systemGray5
            ColorService.shared.setGradientBackgroundOnView(view: backgroundView, firstColor: UIColor(hex: beer.firstColor ?? "#FFFFFF"), secondColor: UIColor(hex: beer.secondColor ?? "#FFFFFF"), cornerRadius: 0)
            
            //UIColor(hex: color).setFill()
            //context.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
            let backgroundImage = backgroundView.asImage()
            let imgRect = CGRect(origin: .zero, size: size)
            backgroundImage.draw(in: imgRect)
            
            // create header, date
            drawLabel(text: beer.getStrDateForSharingImage(), font: UIFont(name: "OktaNeue-Bold", size: 106), fontColor: .black, heightDistance: 0)
            
            // create header, title
            drawLabel(text: "по Пивному Календарю:", font: UIFont(name: "OktaNeue-Bold", size: 72), fontColor: .black, heightDistance: 100)
            
            // create beer name
            drawLabel(text: beer.beerName, font: UIFont(name: "OktaNeue-Bold", size: 60), fontColor: .black, heightDistance: strSizeWidth + 220)
            
            //create brewery name
            drawLabel(text: "\(currentBrewery?.breweryName ?? "breweryName")", font: UIFont(name: "OktaNeue-Light", size: 32), fontColor: .black, heightDistance: strSizeWidth + 290)
            
            //create city name
            drawLabel(text: "\(currentBrewery?.breweryCity ?? "breweryCity")", font: UIFont(name: "OktaNeue-Light", size: 32), fontColor: .black, heightDistance: strSizeWidth + 330)
            
            //create beer type
            var beerType = ""
            if let beerIBU = beer.beerIBU {
                beerType = "\(beer.beerType ?? "") · \(beer.beerABV ?? "") ABV · \(beerIBU) IBU"
            } else {
                beerType = "\(beer.beerType ?? "") · \(beer.beerABV ?? "") ABV"
            }
            drawLabel(text: beerType, font: UIFont(name: "OktaNeue-Light", size: 32), fontColor: .black, heightDistance: strSizeWidth + 370)
            
            //create logo
            let logoRect = CGRect(x: 160, y: firstHeight + strSizeWidth + 450, width: 170, height: 170)
            let image = UIImage(named: "logo300px")!
            image.draw(in: logoRect)
            
            //create appstore 173x569
            let appstoreRect = CGRect(x: 370, y: firstHeight + strSizeWidth + 450, width: 572, height: 174)
            let appStoreImage = UIImage(named: "downloadAppStore")!
            appStoreImage.draw(in: appstoreRect)
            
            
            // create image, last shit
            if let currentBeer = currentBeer, let urlStr = currentBeer.beerLabelURL {
                let url = URL(string: urlStr)!
                let resource = ImageResource(downloadURL: url)
                
                KingfisherManager.shared.retrieveImage(with: resource) { result in
                    switch result {
                    case .success(let value):
                        let beerLabelImage: UIImage = value.image.addShadow(blurSize: 12)
                        let rectImage = CGRect(x: (size.width - self.strSizeWidth) / 2 + 2, y: self.firstHeight + 190, width: self.strSizeWidth, height: self.strSizeWidth)
                        beerLabelImage.draw(in: rectImage, blendMode: .normal, alpha: 1.0)
                        
                        if let newImage = UIGraphicsGetImageFromCurrentImageContext() {
                            UIGraphicsEndImageContext()
                            completion(newImage, nil)
                        }
                        else {
                            UIGraphicsEndImageContext()
                            completion(nil, "Error with UIGraphicsGetImageFromCurrentImageContext")
                        }
                        
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
        } else { // UIGraphicsGetCurrentContext() = nil
            completion(nil, "Error with UIGraphicsGetCurrentContext()")
        }
        UIGraphicsEndImageContext()
    }
    
    let firstHeight: CGFloat = 230
    let strSizeWidth: CGFloat = 896
    
    private func drawLabel(text: String?, font: UIFont?, fontColor: UIColor, heightDistance: CGFloat) {
        let size = CGSize.init(width: 1080, height: 1920)
        let str = "\(text ?? "none")" as NSString
        let strAttributes = [
            NSAttributedString.Key.font : font,
        ]
        let strSize = str.size(withAttributes: strAttributes as [NSAttributedString.Key : Any])
        
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = fontColor
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.drawText(in: CGRect(x: size.width / 2 - strSizeWidth / 2, y: firstHeight + heightDistance, width: strSizeWidth, height: strSize.height))
    }
    
}

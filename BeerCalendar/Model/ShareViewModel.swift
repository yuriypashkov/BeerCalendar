//
//  ShareViewModel.swift
//  BeerCalendar
//
//  Created by Yuriy Pashkov on 8/13/21.
//

import Foundation
import UIKit
import Kingfisher
import Photos


class ShareViewModel {
    
    private var width: CGFloat
    private var height: CGFloat
    var shareView = UIView()
    var isViewShowing = false
    var currentBeer: BeerData?
    
    init(frameWidth: CGFloat, frameHeight: CGFloat) {
        width = frameWidth
        height = frameHeight
        let buttonFrameConstant: CGFloat = 56
        shareView = UIView(frame: CGRect(x: 0, y: height, width: width, height: 100))
        shareView.backgroundColor = .systemGray6
        shareView.roundCorners(corners: [.topLeft, .topRight], radius: 50)
        
        let instaButton = UIButton(frame: CGRect(x: 32, y: 24, width: buttonFrameConstant, height: buttonFrameConstant))
        instaButton.setBackgroundImage(UIImage(named: "iconInst"), for: .normal)
        instaButton.addTarget(self, action: #selector(shareOnInstagramButtonTap), for: .touchUpInside)
        shareView.addSubview(instaButton)
       
        let moreButton = UIButton(frame: CGRect(x: width - 32 - buttonFrameConstant, y: 24, width: buttonFrameConstant, height: buttonFrameConstant))
        moreButton.setBackgroundImage(UIImage(named: "iconShare"), for: .normal)
        moreButton.addTarget(self, action: #selector(showActivityViewController), for: .touchUpInside)
        shareView.addSubview(moreButton)
        
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(hideView))
        swipeDownGesture.direction = .down
        shareView.addGestureRecognizer(swipeDownGesture)
    }
    
    func showView() {
        UIView.animate(withDuration: 0.3) {
            self.shareView.frame = CGRect(x: 0, y: self.height - 100, width: self.width, height: 100)
        } completion: { finished in
            self.isViewShowing.toggle()
        }
    }
    
    @objc func hideView() {
        UIView.animate(withDuration: 0.3) {
            self.shareView.frame = CGRect(x: 0, y: self.height, width: self.width, height: 100)
        } completion: { finished in
            self.isViewShowing.toggle()
        }
    }
    
    @objc func showActivityViewController() {
        if let currentBeer = currentBeer, let urlStr = currentBeer.beerLabelURL {
            
            hideView()
            
            let viewController = UIApplication.shared.windows.first?.rootViewController
            let activitityIndicator = UIActivityIndicatorView()
            activitityIndicator.center = viewController?.view.center ?? CGPoint(x: 30, y: 30)
            activitityIndicator.hidesWhenStopped = true
            activitityIndicator.backgroundColor = .red
            activitityIndicator.startAnimating()
            viewController?.view.addSubview(activitityIndicator)
            
            let text = "Some text"
            let url = URL(string: urlStr)!
            let resource = ImageResource(downloadURL: url)
            KingfisherManager.shared.retrieveImage(with: resource) { result in
                switch result {
                case .success(let value):
                    let image: UIImage = value.image
                    let items: [Any] = [text,image]
                    let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
                    
                    viewController?.present(ac, animated: true, completion: {
                        activitityIndicator.stopAnimating()
                    })
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    @objc func shareOnInstagramButtonTap() {
        hideView()
        
        createImageForInstagram { image, error in
            if let image = image {
                self.shareOnInstagram(image: image)
            }
        }
    }
    
    private func createImageForInstagram(completion: @escaping (_ result: UIImage?, _ error: String?) -> Void) {
        let size = CGSize.init(width: 1080, height: 1920)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        if UIGraphicsGetCurrentContext() != nil {
            let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            let image = UIImage()
            image.draw(in: rect)
            
            let str = "SOME TEXT FOR IMAGE" as NSString
            let strAttributes = [
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 48),
                NSAttributedString.Key.foregroundColor : UIColor.black
            ]
            let strSize = str.size(withAttributes: strAttributes)
            str.draw(in: CGRect(x: 100, y: 100, width: strSize.width, height: strSize.height), withAttributes: strAttributes)
            
            if let currentBeer = currentBeer, let urlStr = currentBeer.beerLabelURL {
                let url = URL(string: urlStr)!
                let resource = ImageResource(downloadURL: url)
                
                KingfisherManager.shared.retrieveImage(with: resource) { result in
                    switch result {
                    case .success(let value):
                        let beerLabelImage: UIImage = value.image
                        let rectImage = CGRect(x: 290 , y: 830, width: 500, height: 500)
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
    
    private func shareOnInstagram(image: UIImage) {
      PHPhotoLibrary.requestAuthorization({
          (newStatus) in
              PHPhotoLibrary.shared().performChanges({
                  PHAssetChangeRequest.creationRequestForAsset(from: image)
              }, completionHandler: { success, error in
                  let fetchOptions = PHFetchOptions()
                  fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                  let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                  if let lastAsset = fetchResult.firstObject {
                      let localIdentifier = lastAsset.localIdentifier
                      let u = "instagram://library?LocalIdentifier=" + localIdentifier
                      DispatchQueue.main.async {
                          UIApplication.shared.open(URL(string: u)!, options: [:], completionHandler: nil)
                      }
                  }
              })
      })
    }
    
}

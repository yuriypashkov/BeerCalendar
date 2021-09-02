//
//  NewShareViewModel.swift
//  BeerCalendar
//
//  Created by Yuriy Pashkov on 8/17/21.
//

import Foundation
import UIKit
import Photos
import Kingfisher

class NewShareViewModel: UIView {
    
    var isViewShowing = false
    var currentBeer: BeerData?
    var currentBrewery: BreweryData?
    let buttonFrameConstant: CGFloat = 32
    var shareButton: UIButton?
    var instaButton = UIButton()
    var moreButton = UIButton()
    var aboutButton = UIButton()
    var instaActivityIndicator = UIActivityIndicatorView()
    var moreActivityIndicator = UIActivityIndicatorView()
    let viewController = UIApplication.shared.windows.first?.rootViewController
    
    init(myFrame: CGRect, shareButton: UIButton) { // 144x48
        super.init(frame: myFrame)
        self.shareButton = shareButton
        backgroundColor = .systemGray5
        layer.cornerRadius = 16
        alpha = 0
        
        setIndicators(indicators: instaActivityIndicator, moreActivityIndicator)
        
        instaButton = UIButton(frame: CGRect(x: 8, y: 8, width: buttonFrameConstant, height: buttonFrameConstant))
        instaButton.setBackgroundImage(UIImage(named: "iconInstaVer2"), for: .normal)
        instaButton.addTarget(self, action: #selector(shareOnInstagramButtonTap), for: .touchUpInside)
        addSubview(instaButton)
        instaButton.addSubview(instaActivityIndicator)
        
        moreButton = UIButton(frame: CGRect(x: 56, y: 8, width: buttonFrameConstant, height: buttonFrameConstant))
        moreButton.setBackgroundImage(UIImage(named: "iconShareVer2"), for: .normal)
        moreButton.addTarget(self, action: #selector(showActivityViewController), for: .touchUpInside)
        addSubview(moreButton)
        moreButton.addSubview(moreActivityIndicator)
        
        aboutButton = UIButton(frame: CGRect(x: 104, y: 8, width: buttonFrameConstant, height: buttonFrameConstant))
        aboutButton.setBackgroundImage(UIImage(named: "iconDolina"), for: .normal)
        aboutButton.addTarget(self, action: #selector(showAboutViewController), for: .touchUpInside)
        addSubview(aboutButton)
        
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(hideView))
        swipeDownGesture.direction = [.right, .left]
        addGestureRecognizer(swipeDownGesture)
        
    }
    
    private func setIndicators(indicators: UIActivityIndicatorView...) {
        for indicator in indicators {
            indicator.color = .white
            indicator.hidesWhenStopped = true
            indicator.center = CGPoint(x: 16, y: 16)
        }
    }
    
    func showView() {
        
        if let shareButton = shareButton {
            UIView.animate(withDuration: 0.1) {
                shareButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }
        }
        
        UIView.animate(withDuration: 0.3) {
            self.transform = CGAffineTransform.identity
            self.alpha = 1
        } completion: { finished in
            self.isViewShowing.toggle()
        }
    }
    
    @objc func hideView() {
        // стопим индикаторы при скрытии шейр-вьюшки
        instaActivityIndicator.stopAnimating()
        moreActivityIndicator.stopAnimating()
        
        if let shareButton = shareButton {
            UIView.animate(withDuration: 0.1) {
                shareButton.transform = CGAffineTransform.identity
            }
        }
        
        UIView.animate(withDuration: 0.3) {
            self.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            self.alpha = 0
        } completion: { finished in
            self.isViewShowing.toggle()
        }
    }
    
    @objc func showAboutViewController() {
        //let viewController = UIApplication.shared.windows.first?.rootViewController
        
        aboutButton.pressedEffect(scale: 0.9) { [weak self] in
            guard let self = self else {return}
            //self.aboutActivityIndicator.stopAnimating()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let aboutViewController = storyboard.instantiateViewController(identifier: "AboutViewController") as! AboutViewController
            aboutViewController.currentBeer = self.currentBeer
            self.viewController?.present(aboutViewController, animated: true, completion: {
                self.hideView()
            })
        }
    }
    
    @objc func showActivityViewController() {
        moreActivityIndicator.startAnimating()
        
        moreButton.pressedEffect(scale: 0.9) { [weak self] in
            self?.methodForShowAVC()
        }
    }
    
    private func methodForShowAVC() {
        if let currentBeer = currentBeer, let urlStr = currentBeer.beerLabelURL {
            
            //let viewController = UIApplication.shared.windows.first?.rootViewController

            func showActivityViewController(content: [Any]) {
                let ac = UIActivityViewController(activityItems: content, applicationActivities: nil)
                viewController?.present(ac, animated: true, completion: {
                    self.hideView()
                })
            }
            
            let text = "\(currentBeer.beerName ?? "beerName") - пиво дня \(currentBeer.getStrDateForSharingImage() ?? "beerDate"), согласно пивному календарю! @Beer.Calendar #BeerCalendar https://apps.apple.com/ru/app/id1581340486"

            guard let url = URL(string: urlStr) else {
                showActivityViewController(content: [text])
                return
            }
            
            let resource = ImageResource(downloadURL: url)
            KingfisherManager.shared.retrieveImage(with: resource) { result in
                switch result {
                case .success(let value):
                    let image: UIImage = value.image
                    let items: [Any] = [text,image]
                    
                    showActivityViewController(content: items)
                case .failure(let error):
                    showActivityViewController(content: [text])
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    
    
    @objc func shareOnInstagramButtonTap() {
        instaActivityIndicator.startAnimating()

            instaButton.pressedEffect(scale: 0.9) { [weak self] in
                
                guard let self = self else {return}
                
                PictureCreator.shared.createImageForInstagram(currentBeer: self.currentBeer, currentBrewery: self.currentBrewery) { image, error in
                    
                    if let image = image {
                        self.hideView()
                        self.shareOnInstagram(image: image)
                    }
                    if let error = error {
                        print(error)
                    }
                }
            }
  
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
                        if let url = URL(string: u), UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        } else {
                            let alert = AlertManager.shared.createAlert(title: "Ошибочка вышла", text: "У вас не установлено приложение Instagram")
                            //let viewController = UIApplication.shared.windows.first?.rootViewController
                            self.viewController?.present(alert, animated: true, completion: nil)
                        }
                      }
                  }
              })
      })
    }
 
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

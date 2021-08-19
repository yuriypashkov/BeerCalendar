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
    
    init(myFrame: CGRect) { // 96x48
        super.init(frame: myFrame)
        backgroundColor = .systemGray5
        layer.cornerRadius = 16
        alpha = 0
        
        let instaButton = UIButton(frame: CGRect(x: 8, y: 8, width: buttonFrameConstant, height: buttonFrameConstant))
        instaButton.setBackgroundImage(UIImage(named: "iconInstSVG"), for: .normal)
        instaButton.addTarget(self, action: #selector(shareOnInstagramButtonTap), for: .touchUpInside)
        addSubview(instaButton)
        
        let moreButton = UIButton(frame: CGRect(x: 56, y: 8, width: buttonFrameConstant, height: buttonFrameConstant))
        moreButton.setBackgroundImage(UIImage(named: "iconMoreSVG"), for: .normal)
        moreButton.addTarget(self, action: #selector(showActivityViewController), for: .touchUpInside)
        addSubview(moreButton)
        
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(hideView))
        swipeDownGesture.direction = .right
        addGestureRecognizer(swipeDownGesture)
        
    }
    
    func showView() {
        UIView.animate(withDuration: 0.3) {
            self.transform = CGAffineTransform.identity
            self.alpha = 1
        } completion: { finished in
            self.isViewShowing.toggle()
        }
    }
    
    @objc func hideView() {
        
        UIView.animate(withDuration: 0.3) {
            self.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            self.alpha = 0
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
            
            func showActivityViewController(content: [Any]) {
                let ac = UIActivityViewController(activityItems: content, applicationActivities: nil)
                
                viewController?.present(ac, animated: true, completion: {
                    activitityIndicator.stopAnimating()
                })
            }
            
            let text = "\(currentBeer.beerName ?? "beerName") - пиво дня \(currentBeer.getStrDateForSharingImage() ?? "beerDate"), согласно пивному календарю! @Beer.Calendar #BeerCalendar https://apps.apple.com/ru/app/id1581340486"
            
            guard let url = URL(string: urlStr) else {
                showActivityViewController(content: [text])
//                let items = [text]
//                let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
//
//                viewController?.present(ac, animated: true, completion: {
//                    activitityIndicator.stopAnimating()
//                })
                return
            }
            
            let resource = ImageResource(downloadURL: url)
            KingfisherManager.shared.retrieveImage(with: resource) { result in
                switch result {
                case .success(let value):
                    let image: UIImage = value.image
                    let items: [Any] = [text,image]
                    showActivityViewController(content: items)
//                    let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
//
//                    viewController?.present(ac, animated: true, completion: {
//                        activitityIndicator.stopAnimating()
//                    })
                case .failure(let error):
                    showActivityViewController(content: [text])
//                    let items = [text]
//                    let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
//
//                    viewController?.present(ac, animated: true, completion: {
//                        activitityIndicator.stopAnimating()
//                    })
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    
    
    @objc func shareOnInstagramButtonTap() {
        hideView()
        
        PictureCreator.shared.createImageForInstagram(currentBeer: currentBeer, currentBrewery: currentBrewery) { image, error in
            
            if let image = image {
               self.shareOnInstagram(image: image)
            }
            if let error = error {
                print(error)
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
                          UIApplication.shared.open(URL(string: u)!, options: [:], completionHandler: nil)
                      }
                  }
              })
      })
    }
 
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

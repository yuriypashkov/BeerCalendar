//
//  InfoViewController.swift
//  BeerCalendar
//
//  Created by Yuriy Pashkov on 8/10/21.
//

import UIKit
import MarqueeLabel
import Kingfisher

class InfoViewController: UIViewController {
    
    @IBOutlet weak var aboutBeerLabel: UILabel!
    @IBOutlet weak var aboutBreweryLabel: UILabel!
    @IBOutlet weak var siteButton: UIButton!
    @IBOutlet weak var instaButton: UIButton!
    @IBOutlet weak var vkButton: UIButton!
    @IBOutlet weak var fbButton: UIButton!
    @IBOutlet weak var untappdButton: UIButton!
    @IBOutlet weak var breweryNameLabel: UILabel!
    @IBOutlet weak var beerNameLabel: UILabel!
    @IBOutlet weak var specialInfoTitleLabel: UILabel!
    @IBOutlet weak var specialInfoLabel: UILabel!
    @IBOutlet weak var constraintBeerNameBtwSpecialLabel: NSLayoutConstraint!
    @IBOutlet weak var constraintSpecialInfoBtwTitle: NSLayoutConstraint!
    @IBOutlet weak var constraintSpecialTitleTop: NSLayoutConstraint!
    @IBOutlet weak var mainSubview: UIView!
    @IBOutlet weak var breweryLogoImageView: UIImageView!
    
    
    var currentBeer: BeerData?
    var currentBrewery: BreweryData?

    override func viewDidLoad() {
        super.viewDidLoad()
        //scrollView.delegate = self
        setUI()
    }
    

    
    private func setUI() {
        mainSubview.alpha = 0
        //set brewerylogo
        if let strUrl = currentBrewery?.logoURL, let url = URL(string: strUrl) {
            breweryLogoImageView.kf.indicatorType = .activity
            breweryLogoImageView.kf.setImage(with: url, placeholder: nil, options: nil) { result in
                switch result {
                case .success(let image):
                    self.breweryLogoImageView.image = image.image
                case .failure:
                    self.breweryLogoImageView.image = UIImage(named: "wrongBeer")
                }
            }
        } else {
            breweryLogoImageView.image = UIImage(named: "wrongBeer")
        }
        //set mainbackground
        view.backgroundColor = .systemGray5
        if let firstColorStr = currentBeer?.firstColor, let secondColorStr = currentBeer?.secondColor {
            ColorService.shared.setGradientBackgroundOnView(view: view, firstColor: UIColor(hex: secondColorStr), secondColor: UIColor(hex: firstColorStr), cornerRadius: 0)
        }
        // ???????????????????? ???????????????? ??????????????
        aboutBeerLabel.text = currentBeer?.beerDescription
        aboutBreweryLabel.text = currentBrewery?.aboutBrewery
        breweryNameLabel.text = currentBrewery?.breweryName
        let beerTitle = "\(currentBeer?.beerName ?? "beerName") ?? \(currentBeer?.beerType ?? "beerType"), \(currentBeer?.beerABV ?? "")"
        beerNameLabel.text = beerTitle
        
        // ????????????????????/???? ???????????????????? ???????????? ????????
        if currentBeer?.beerSpecialInfoTitle == nil {
            specialInfoTitleLabel.isHidden = true
            constraintSpecialTitleTop.constant = 0
            constraintSpecialInfoBtwTitle.constant = 0
        } else {
            specialInfoTitleLabel.text = currentBeer?.beerSpecialInfoTitle
        }
        
        if currentBeer?.beerSpecialInfo == nil {
            specialInfoLabel.isHidden = true
            constraintBeerNameBtwSpecialLabel.constant = 0
        } else {
            specialInfoLabel.text = currentBeer?.beerSpecialInfo
        }
        
        // ?????????????????????? ???????????? ???????????? ?? ?????????????????????? ???? ????????, ?????????? ?????????? ????????
        if currentBrewery?.siteURL == nil {
            siteButton.isHidden = true
        }
        if currentBrewery?.instaURL == nil {
            instaButton.isHidden = true
        }
        if currentBrewery?.vkURL == nil {
            vkButton.isHidden = true
        }
        if currentBrewery?.fbURL == nil {
            fbButton.isHidden = true
        }
        if currentBrewery?.untappdURL == nil {
            untappdButton.isHidden = true
        }

        // ???????????????? ???????????????????? ????????, ???????? ?????????? ???????????????????? ???????????????????????? ??????????
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UIView.animate(withDuration: 0.6) {
                if self.mainSubview.frame.size.height < self.view.frame.size.height {
                    self.view.frame.origin = CGPoint(x: self.view.frame.origin.x, y: self.view.frame.origin.y + (self.view.frame.size.height - self.mainSubview.frame.size.height))
                }
            }
        }
        
        // ???????????????????? ???????? ????????????, ???? ?????? ???????????????????? ?????????????????????? ?????????? ???????????? ?????????????????????? ????????
        view.roundCorners(corners: [.topLeft, .topRight], radius: 12)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // ?????? ???????????????? ?????????????????? ????????????
        UIView.animate(withDuration: 0.4) {
            self.mainSubview.alpha = 1
        }
    }
    
    

    @IBAction func socialButtonTap(_ sender: UIButton) {
        
        sender.pressedEffect(scale: 0.9) { [weak self] in
            guard let self = self else {return}
            switch sender.tag {
            case 0:
                if let urlStr = self.currentBrewery?.siteURL {
                    self.openURL(urlStr: urlStr)
                }
            case 1:
                if let urlStr = self.currentBrewery?.instaURL {
                    self.openURL(urlStr: urlStr)
                }
            case 2:
                if let urlStr = self.currentBrewery?.vkURL {
                    self.openURL(urlStr: urlStr)
                }
            case 3:
                if let urlStr = self.currentBrewery?.fbURL {
                    self.openURL(urlStr: urlStr)
                }
            case 4:
                if let id = self.currentBrewery?.untappdID {
                    guard let urlForUntappd = URL(string: "untappd://brewery/\(id)") else {return}
                    if UIApplication.shared.canOpenURL(urlForUntappd) {
                        UIApplication.shared.open(urlForUntappd, options: [:], completionHandler: nil)
                    } else {
                        guard let urlStr = self.currentBrewery?.untappdURL else {return}
                        self.openURL(urlStr: urlStr)
                    }
                }
            default: ()
            }
        }
        
    }
    
    private func openURL(urlStr: String) {
        if let url = URL(string: urlStr) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
}

//
//  InfoViewController.swift
//  BeerCalendar
//
//  Created by Yuriy Pashkov on 8/10/21.
//

import UIKit

class InfoViewController: UIViewController {
    
    @IBOutlet weak var aboutBeerLabel: UILabel!
    @IBOutlet weak var aboutBreweryLabel: UILabel!
    @IBOutlet weak var siteButton: UIButton!
    @IBOutlet weak var instaButton: UIButton!
    @IBOutlet weak var vkButton: UIButton!
    @IBOutlet weak var fbButton: UIButton!
    
    
    var currentBeer: BeerData?
    var currentBrewery: BreweryData?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    private func setUI() {
        aboutBeerLabel.text = currentBeer?.aboutBeer
        aboutBreweryLabel.text = currentBrewery?.aboutBrewery
        if currentBrewery?.siteUrl == nil {
            siteButton.isHidden = true
        }
        if currentBrewery?.instaUrl == nil {
            instaButton.isHidden = true
        }
        if currentBrewery?.vkUrl == nil {
            vkButton.isHidden = true
        }
        if currentBrewery?.fbUrl == nil {
            fbButton.isHidden = true
        }
    }

    @IBAction func socialButtonTap(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            print("WWW TAP")
            if let urlStr = currentBrewery?.siteUrl {
                openURL(urlStr: urlStr)
            }
        case 1:
            print("INSTA TAP")
            if let urlStr = currentBrewery?.instaUrl {
                openURL(urlStr: urlStr)
            }
        case 2:
            print("VK TAP")
            if let urlStr = currentBrewery?.vkUrl {
                openURL(urlStr: urlStr)
            }
        case 3:
            print("FB TAP")
            if let urlStr = currentBrewery?.fbUrl {
                openURL(urlStr: urlStr)
            }
        default: ()
        }
        
    }
    
    private func openURL(urlStr: String) {
        let url = URL(string: urlStr)!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    
    
}

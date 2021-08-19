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
        aboutBeerLabel.text = currentBeer?.beerDescription
        aboutBreweryLabel.text = currentBrewery?.aboutBrewery
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
    }

    @IBAction func socialButtonTap(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            print("WWW TAP")
            if let urlStr = currentBrewery?.siteURL {
                openURL(urlStr: urlStr)
            }
        case 1:
            print("INSTA TAP")
            if let urlStr = currentBrewery?.instaURL {
                openURL(urlStr: urlStr)
            }
        case 2:
            print("VK TAP")
            if let urlStr = currentBrewery?.vkURL {
                openURL(urlStr: urlStr)
            }
        case 3:
            print("FB TAP")
            if let urlStr = currentBrewery?.fbURL {
                openURL(urlStr: urlStr)
            }
        default: ()
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

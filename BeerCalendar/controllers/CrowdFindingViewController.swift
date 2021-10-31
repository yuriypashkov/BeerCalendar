//
//  CrowdFindingViewController.swift
//  BeerCalendar
//
//  Created by Yuriy Pashkov on 8/12/21.
//

import UIKit
import Kingfisher

class CrowdFindingViewController: UIViewController {
    
    @IBOutlet weak var goToButton: UIButton!
    @IBOutlet weak var mainImageView: UIImageView!
    var imageURL: String?
    var jumpURL: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        goToButton.layer.cornerRadius = goToButton.frame.size.width / 2
        if let urlStr = imageURL, let url = URL(string: urlStr) {
            mainImageView.kf.setImage(with: url)
        }
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapOnImage))
        mainImageView.isUserInteractionEnabled = true
        mainImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func tapOnImage() {
        if let strUrl = jumpURL, let url = URL(string: strUrl), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:]) { finished in
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func goToButtonTap(_ sender: UIButton) {
        sender.pressedEffect(scale: 0.96) { [weak self] in
            if let strUrl = self?.jumpURL, let url = URL(string: strUrl), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:]) { finished in
                    self?.dismiss(animated: true, completion: nil)
                }
            }
        }
        
    }
    

}

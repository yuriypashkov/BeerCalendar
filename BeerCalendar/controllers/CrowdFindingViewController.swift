//
//  CrowdFindingViewController.swift
//  BeerCalendar
//
//  Created by Yuriy Pashkov on 8/12/21.
//

import UIKit
import Kingfisher

class CrowdFindingViewController: UIViewController {
    
    @IBOutlet weak var mainImageView: UIImageView!
    var imageURL: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let urlStr = imageURL, let url = URL(string: urlStr) {
            mainImageView.kf.setImage(with: url)
        }
        
    }
    
    
    

}

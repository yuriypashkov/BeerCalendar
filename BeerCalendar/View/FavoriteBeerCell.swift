//
//  FavoriteBeerCell.swift
//  BeerCalendar
//
//  Created by Yuriy Pashkov on 8/4/21.
//

import UIKit
import Kingfisher

class FavoriteBeerCell: UITableViewCell {

    
    @IBOutlet weak var beerImage: UIImageView!
    @IBOutlet weak var beerNameLabel: UILabel!
    @IBOutlet weak var beerTypeLabel: UILabel!
    
    func setCell(beer: BeerData) {
        beerImage.layer.cornerRadius = beerImage.frame.size.width / 2
        if let previewStr = beer.beerLabelPreviewURL,  let url = URL(string: previewStr) {
            beerImage.kf.setImage(with: url)
        }
        beerNameLabel.text = beer.beerName
        beerTypeLabel.text = beer.beerType
        contentView.backgroundColor = .systemGray6
    }
    
}

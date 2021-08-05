//
//  FavoriteBeerCell.swift
//  BeerCalendar
//
//  Created by Yuriy Pashkov on 8/4/21.
//

import UIKit

class FavoriteBeerCell: UITableViewCell {

    
    @IBOutlet weak var titleLabel: UILabel!
    
    func setCell(beer: BeerData) {
        titleLabel.text = "\(beer.beerDate ?? "") · \(beer.beerName ?? "")"
    }
    
}

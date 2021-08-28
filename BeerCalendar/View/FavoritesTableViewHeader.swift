//
//  FavoritesTableViewHeader.swift
//  BeerCalendar
//
//  Created by Yuriy Pashkov on 8/16/21.
//

import Foundation
import UIKit

class FavoritesTableViewHeader: UITableViewHeaderFooterView {
    
    let title = UILabel()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureContents()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureContents() {
        //contentView.backgroundColor = .systemGray6
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = UIFont(name: "OktaNeue-Medium", size: 18)
        title.textColor = .darkGray
        contentView.addSubview(title)
        NSLayoutConstraint.activate([
            title.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            title.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
        
    }
    
}

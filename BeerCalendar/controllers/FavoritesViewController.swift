//
//  FavoritesViewController.swift
//  BeerCalendar
//
//  Created by Yuriy Pashkov on 8/4/21.
//

import UIKit

class FavoritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoritesBeer.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteBeerCell") as! FavoriteBeerCell
        cell.setCell(beer: favoritesBeer[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            self.delegate?.goToChoosenFavoriteBeer(beer: self.favoritesBeer[indexPath.row])
        }
    }
    
    
    var favoritesBeer = [BeerData]()
    var delegate: MainViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    

}

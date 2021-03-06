//
//  FavoritesViewController.swift
//  BeerCalendar
//
//  Created by Yuriy Pashkov on 8/4/21.
//

import UIKit

class FavoritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
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
            self.delegate?.goToChooseneBeer(choosenBeer: self.favoritesBeer[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "FavoritesTableViewHeader") as! FavoritesTableViewHeader
        view.title.text = "Избранное"
        return view
    }
    
    
    
    var favoritesBeer = [BeerData]()
    var delegate: MainViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .systemGray5
        
        tableView.register(FavoritesTableViewHeader.self, forHeaderFooterViewReuseIdentifier: "FavoritesTableViewHeader")

//        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeDown(_:)))
//        swipeDownGesture.direction = .down
//        view.addGestureRecognizer(swipeDownGesture)
    }
    

    
    @objc func swipeDown(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        //view.roundCorners(corners: [.topLeft, .topRight], radius: 10.0)
    }

//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(true)
//        //print("Tableview Height: \(tableView.contentSize.height)")
//        var newFrameHeight: CGFloat = 0
//        //newFrameHeight = view.frame.size.height / 3
//        if tableView.contentSize.height > view.frame.size.height / 2 {
//            newFrameHeight = view.frame.size.height - tableView.contentSize.height
//        } else {
//            newFrameHeight = view.frame.size.height / 2
//        }
//        UIView.animate(withDuration: 0.5) {
//            self.view.frame = CGRect(x: 0, y: newFrameHeight, width: self.view.frame.size.width, height: self.view.frame.size.height)
//        }
//    }
    
    

}

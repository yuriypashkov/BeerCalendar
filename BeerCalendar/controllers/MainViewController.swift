//
//  ViewController.swift
//  BeerCalendar
//
//  Created by Yuriy Pashkov on 7/26/21.
//

import UIKit
import Kingfisher
import DataCache

class MainViewController: UIViewController, MainViewControllerDelegate {
    
    // MARK: - IB Outlets
    @IBOutlet weak var beerLabelView: UIView!
    @IBOutlet weak var beerNameLabel: UILabel!
    @IBOutlet weak var beerTypeLabel: UILabel!
    @IBOutlet weak var beerLabelImage: UIImageView!
    @IBOutlet weak var beerDateDayLabel: UILabel!
    @IBOutlet weak var beerDateMonthLabel: UILabel!
    @IBOutlet weak var beerManufacturerLabel: UILabel!
    @IBOutlet weak var beerInfoTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var dateStackViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var beerInfoStackView: UIStackView!
    @IBOutlet weak var addToFavoriteButton: UIButton!
    @IBOutlet weak var favoritesButton: UIButton!
    @IBOutlet weak var untappdButton: UIButton!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var goToTodayButton: UIButton!
    
    
    
    var calendarModel: CalendarModel?
    var messageViewModel: MessageViewModel!
    let activityIndicatorView = UIActivityIndicatorView()
    var currentBeerID: Int = 0
    var favoriteBeersModel = FavoriteBeersModel()
    var soundService = SoundService() // воспроизведение звуков
    let generator = UIImpactFeedbackGenerator(style: .heavy) // генератор вибрации

    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageViewModel = MessageViewModel(x: view.frame.size.width, y: view.frame.size.height, width: view.frame.size.width, height: 100)
        view.addSubview(messageViewModel.messageView)

        addGestures()
        
        prepareUI()
        
        loadData()
    }
    

    @objc func swipeMessageViewDown() {
        messageViewModel.hideMessageView()
    }
    
    @objc func swipeUp(_ recognizer: UISwipeGestureRecognizer) {
        if let nextBeer = calendarModel?.getNextBeer() {

            soundService.playRandomSound()
            
            switch recognizer.state {
            case .ended:
                    UIView.transition(with: beerLabelView,
                                      duration: 0.7,
                                      options: [.transitionCurlUp],
                                      animations: {
                                        self.setUI(beer: nextBeer)
                                      })
            default: break
            }
        } else {
            // показываем сообщение что следующее пиво можно увидеть только на следующий день
            if !messageViewModel.isMessageViewShow {
                messageViewModel.showMessageView()

                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    if self.messageViewModel.isMessageViewShow {
                        self.messageViewModel.hideMessageView()
                    }
                }
                
            }
        }
    }
    
    @objc func swipeDown(_ recognizer: UIGestureRecognizer) {
        if let previousBeer = calendarModel?.getPreviousBeer() {

            soundService.playRandomSound()
            
            switch recognizer.state {
            case .ended:
                if messageViewModel.isMessageViewShow {
                    messageViewModel.hideMessageView()
                }
                UIView.transition(with: beerLabelView,
                                  duration: 0.7,
                                  options: [.transitionCurlDown]) {
                    self.setUI(beer: previousBeer)
                }

            default: break
            }
        }
    }
    
    @objc func doubleTapOnImage() {
        if favoriteBeersModel.isCurrentBeerFavorite(id: currentBeerID) {
            favoriteBeersModel.removeBeerFromFavorites(id: currentBeerID)
            addToFavoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
        } else {
            generator.impactOccurred()
            favoriteBeersModel.saveBeerToFavorites(id: currentBeerID)
            addToFavoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
        }
    }
    
    func goToChoosenFavoriteBeer(beer: BeerData) {
        // если находимся на нём же, то переворачивать страничку не надо
        guard let id = beer.id, let calendar = calendarModel, id != currentBeerID else { return }
        
        //перелистываем страничку
        //обновляем UI
        //устанавливаем currentIndex в модели
        if calendar.setCurrentIndexForChoosenFavoriteBeer(beerID: id) {
            soundService.playRandomSound()
            UIView.transition(with: beerLabelView,
                              duration: 0.7,
                              options: [.transitionCurlUp],
                              animations: {
                                self.setUI(beer: beer)
                              })
        }
        
    }
    
    private func addGestures() {
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeDown(_:)))
        swipeDownGesture.direction = .down
        beerLabelView.addGestureRecognizer(swipeDownGesture)
        
        let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeUp(_:)))
        swipeUpGesture.direction = .up
        beerLabelView.addGestureRecognizer(swipeUpGesture)
        
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeDown(_:)))
        swipeLeftGesture.direction = .left
        beerLabelView.addGestureRecognizer(swipeLeftGesture)
        
        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeUp(_:)))
        swipeRightGesture.direction = .right
        beerLabelView.addGestureRecognizer(swipeRightGesture)
        
        let swipeMessageViewDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeMessageViewDown))
        swipeMessageViewDownGesture.direction = .down
        messageViewModel.messageView.addGestureRecognizer(swipeMessageViewDownGesture)
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapOnImage))
        doubleTapGesture.numberOfTapsRequired = 2
        beerLabelImage.isUserInteractionEnabled = true
        beerLabelImage.addGestureRecognizer(doubleTapGesture)
    }
    
    private func goToTodayBeer() {
        if let calendar = calendarModel, let beer = calendar.getCurrentBeer(), let secondBeer = calendar.getBeerForID(id: currentBeerID) {
            //если разница в один день, то просто вызвать обычный оборот странички
            if calendar.haveOneDayBetweenTwoBeers(firstBeer: beer, secondBeer: secondBeer) {
                soundService.playRandomSound()
                UIView.transition(with: beerLabelView,
                              duration: 0.7,
                              options: [.transitionCurlUp],
                              animations: {
                                self.setUI(beer: beer)
                              })

            }
            else {
            //если разницы больше одного дня, то
                setElementsAlpha(value: 0)
                soundService.playShortSound()
                UIView.transition(with: beerLabelView,
                              duration: 0.3,
                              options: .transitionCurlUp) {
                                        self.beerLabelView.backgroundColor = .systemGray4
                            } completion: { final in
                                self.soundService.playShortSound()
                                UIView.transition(with: self.beerLabelView, duration: 0.3, options: .transitionCurlUp) {
                                    self.beerLabelView.backgroundColor = .systemGray5
                                } completion: { final in
                                    self.soundService.playShortSound()
                                    UIView.transition(with: self.beerLabelView, duration: 0.3, options: .transitionCurlUp) {
                                        self.setUI(beer: beer)
                                    } completion: { final in }
                                }

                            }
            }
        }
        
    }
    
    private func loadData() {
        activityIndicatorView.startAnimating()
        
        NetworkService.shared.requestData { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let beerData):
                    //пишем в кэш полученные данные
                    do {
                        try DataCache.instance.write(codable: beerData, forKey: "beerDataArray")
                    } catch {
                        print(error)
                    }
                    //грузим данные в модель, рисуем UI на текущую дату
                    self.calendarModel = CalendarModel(beerData: beerData)
                    let item = self.calendarModel?.getCurrentBeer()
                    if let item = item {
                        self.setUI(beer: item)
                    } else {
                        self.beerLabelView.backgroundColor = .systemGray
                        self.beerNameLabel.text = "Не найдено пиво на текущую дату"
                        self.beerNameLabel.alpha = 1
                    }
                case .failure(let requestError):
                    print(requestError)
                    // если запрос ничего не вернул - вытягиваем данные из кэша
                     do {
                        let beerDataFromCache: [BeerData]? = try DataCache.instance.readCodable(forKey: "beerDataArray")
                        
                        guard let beerData = beerDataFromCache else {
                            self.activityIndicatorView.stopAnimating()
                            self.beerLabelView.backgroundColor = .systemGray
                            self.beerNameLabel.text = "Проблема с подключением к интернету"
                            self.beerNameLabel.alpha = 1
                            self.messageViewModel.isMessageViewShow = true // ???
                            return
                        }
                        self.calendarModel = CalendarModel(beerData: beerData)
                        let item = self.calendarModel?.getCurrentBeer()
                        if let item = item {
                            self.setUI(beer: item)
                        } else {
                            self.beerLabelView.backgroundColor = .systemGray
                            self.beerNameLabel.text = "Не найдено пиво на текущую дату"
                            self.beerNameLabel.alpha = 1
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                
                self.activityIndicatorView.stopAnimating()
            }
        }
    }
    
    func setUI(beer: BeerData) {
        currentBeerID = beer.id ?? 0
        beerLabelView.backgroundColor = UIColor(hex: beer.backgroundColor!)
        beerNameLabel.text = beer.beerName
        beerTypeLabel.text = "\(beer.beerType ?? "") · \(beer.beerABV ?? "") ABV · \(beer.beerIBU ?? 0) IBU"
        beerManufacturerLabel.text = beer.beerManufacturer
        if let dateArray = beer.getStrDate() {
            beerDateDayLabel.text = dateArray[0]
            beerDateMonthLabel.text = dateArray[1]
        }
        if let strUrl = beer.beerLabelURL, let url = URL(string: strUrl) {
            beerLabelImage.kf.indicatorType = .activity
            beerLabelImage.kf.setImage(with: url)
        }
        
        setElementsAlpha(value: 1)
        
        if favoriteBeersModel.isCurrentBeerFavorite(id: currentBeerID) {
            addToFavoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
        } else {
            addToFavoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
        }
        
        if calendarModel?.currentIndex == calendarModel?.borderIndex {
            goToTodayButton.isEnabled = false
        } else {
            goToTodayButton.isEnabled = true
        }
    }
    
    private func setElementsAlpha(value: CGFloat) {
        addToFavoriteButton.alpha = value
        untappdButton.alpha = value
        favoritesButton.alpha = value
        infoButton.alpha = value
        shareButton.alpha = value
        beerLabelImage.alpha = value
        beerNameLabel.alpha = value
        beerTypeLabel.alpha = value
        beerManufacturerLabel.alpha = value
        beerDateDayLabel.alpha = value
        beerDateMonthLabel.alpha = value
        goToTodayButton.alpha = value
    }
    
    private func prepareUI() {
        setElementsAlpha(value: 0)
        
        activityIndicatorView.center = view.center
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.style = .large
        activityIndicatorView.color = .red
        view.addSubview(activityIndicatorView)
        
        switch view.frame.size.height {
        case 0...568:
            //print("SE 1th")
            beerInfoTopConstraint.constant = 8
            dateStackViewTopConstraint.constant = 8
            beerDateDayLabel.font = beerDateDayLabel.font.withSize(48) //64 and 36
            beerDateMonthLabel.font = beerDateDayLabel.font.withSize(22)
            beerInfoStackView.spacing = 4
        case 568...750:
            //print("SE 2th and Plus")
            beerInfoTopConstraint.constant = 12
            dateStackViewTopConstraint.constant = 12
            beerDateDayLabel.font = beerDateDayLabel.font.withSize(56)
            beerDateMonthLabel.font = beerDateMonthLabel.font.withSize(28)
            beerInfoStackView.spacing = 6
        default: break
        }
    }
    
    @IBAction func untappdButtonTap(_ sender: UIButton) {
        if let calendar = calendarModel {
            let currentIndex = calendar.currentIndex
            let currentBeer = calendar.beers[currentIndex]
            if let untappdUrl = currentBeer.untappdURL {
                let url = URL(string: untappdUrl)!
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:])
                }
            }
        }
    }
    
    @IBAction func addToFavoriteButtonTap(_ sender: UIButton) {

        if favoriteBeersModel.isCurrentBeerFavorite(id: currentBeerID) {
            favoriteBeersModel.removeBeerFromFavorites(id: currentBeerID)
            addToFavoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
        } else {
            generator.impactOccurred()
            favoriteBeersModel.saveBeerToFavorites(id: currentBeerID)
            addToFavoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
        }
    }
    
    
    @IBAction func favoritesButtonTap(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let favoritesViewController = storyboard.instantiateViewController(identifier: "FavoritesViewController") as? FavoritesViewController else {return}
        favoritesViewController.favoritesBeer = calendarModel?.getListOfFavoritesBeers(listOfBeersID: favoriteBeersModel.listOfFavoriteBeers) ?? [BeerData]()
        favoritesViewController.delegate = self
        favoritesViewController.transitioningDelegate = self
        favoritesViewController.modalPresentationStyle = .custom
        present(favoritesViewController, animated: true, completion: nil)
    }
    
    
    @IBAction func shareButtonTap(_ sender: UIButton) {
        
    }
    
    
    @IBAction func goToTodayButtonTap(_ sender: UIButton) {
        goToTodayBeer()
    }
    


}

extension MainViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return PartialSizePresentViewController(presentedViewController: presented, presenting: presenting, withRatio: 0.8)
    }
    
}


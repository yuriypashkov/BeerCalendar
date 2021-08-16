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
    var breweriesModel: BreweriesModel?
    var messageViewModel: MessageViewModel!
    var shareViewModel: ShareViewModel!
    let activityIndicatorView = UIActivityIndicatorView()
    var currentBeerID: Int = 0
    var favoriteBeersModel = FavoriteBeersModel()
    var soundService = SoundService() // воспроизведение звуков
    let generator = UIImpactFeedbackGenerator(style: .heavy) // генератор вибрации
    var currentFontColor: UIColor = .black

    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageViewModel = MessageViewModel(x: view.frame.size.width, y: view.frame.size.height, width: view.frame.size.width, height: 100)
        view.addSubview(messageViewModel.messageView)
        
        shareViewModel = ShareViewModel(frameWidth: view.frame.size.width, frameHeight: view.frame.size.height)
        view.addSubview(shareViewModel.shareView)

        addGestures()
        
        prepareUI()
        
        //loadData()
        loadBeersAndBrewries()
    }
    

    @objc func swipeMessageViewDown() {
        messageViewModel.hideMessageView()
    }
    
    @objc func swipeUp(_ recognizer: UISwipeGestureRecognizer) {
        if let nextBeer = calendarModel?.getNextBeer() {

            soundService.playRandomSound()
            
            switch recognizer.state {
            case .ended:
                if shareViewModel.isViewShowing {
                    shareViewModel.hideView()
                }
                    UIView.transition(with: beerLabelView,
                                      duration: 0.7,
                                      options: [.transitionCurlUp],
                                      animations: {
                                        self.setUI(beer: nextBeer)
                                      }) { finished in
                        if let calendar = self.calendarModel, calendar.showCrowdFinding() {
                            // показать рекламу
                            self.showCrowdFindingController()
                        }
                    }
            default: break
            }
        } else {
            // показываем сообщение что следующее пиво можно увидеть только на следующий день
            if !messageViewModel.isMessageViewShow {
                messageViewModel.showMessageView()

                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
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
                if shareViewModel.isViewShowing {
                    shareViewModel.hideView()
                }
                if messageViewModel.isMessageViewShow {
                    messageViewModel.hideMessageView()
                }
                UIView.transition(with: beerLabelView,
                                  duration: 0.7,
                                  options: [.transitionCurlDown],
                                  animations: {self.setUI(beer: previousBeer)}) { finished in
                    if let calendar = self.calendarModel, calendar.showCrowdFinding() {
                        // показать рекламу
                        self.showCrowdFindingController()
                    }
                }

            default: break
            }
        }
    }
    
    @objc func doubleTapOnImage() {
        addToFavorites()
    }
    
    private func showCrowdFindingController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let crowdFindingController = storyboard.instantiateViewController(identifier: "CrowdFindingViewController") as? CrowdFindingViewController, let calendar = calendarModel {
            crowdFindingController.imageURL = calendar.crowdFindingData?.imgUrl
            present(crowdFindingController, animated: true, completion: nil)
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
        
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeUp(_:)))
        swipeLeftGesture.direction = .left
        beerLabelView.addGestureRecognizer(swipeLeftGesture)
        
        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeDown(_:)))
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
        if let calendar = calendarModel, let beer = calendar.getTodayBeer(), let secondBeer = calendar.getBeerForID(id: currentBeerID) {
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
                                        self.beerLabelView.backgroundColor = .systemGray2
                            } completion: { final in
                                self.soundService.playShortSound()
                                UIView.transition(with: self.beerLabelView, duration: 0.3, options: .transitionCurlUp) {
                                    self.beerLabelView.backgroundColor = .systemGray2
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
    
    private func sayAboutInternetError() {
        activityIndicatorView.stopAnimating()
        beerLabelView.backgroundColor = .systemGray
        beerNameLabel.text = "Проблема с подключением"
        beerNameLabel.textAlignment = .center
        beerNameLabel.alpha = 1
        messageViewModel.isMessageViewShow = true
    }
    
    
    private func loadBeersAndBrewries() {
        activityIndicatorView.startAnimating()
        
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        
        NetworkService.shared.requestBeerData { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let beerData):
                    self.calendarModel = CalendarModel(beerData: beerData)
                    //пишем в кэш полученные данные о пивах
                    do {
                        try DataCache.instance.write(codable: beerData, forKey: "beerDataArray")
                    } catch {
                        print(error)
                    }
                case .failure(let requestError): // если ошибка запроса - читаем данные из кэша и инициализируем модель. Если в кэше ничего нет - выводим ошибку о проблеме с подключением
                    print("Beers error: \(requestError)")
                    do {
                        let beerDataFromCache: [BeerData]? = try DataCache.instance.readCodable(forKey: "beerDataArray")
                        guard let beerData = beerDataFromCache else {
                            // здесь обработка ситуации: нет инета и нет ничего в кэше по пивам, в .notify не улетаем
                            self.sayAboutInternetError()
                            print("Beers don't cached")
                            return
                        }
                        self.calendarModel = CalendarModel(beerData: beerData)
                    }
                    catch {
                        print(error.localizedDescription)
                    }
                }
                
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.enter()
        NetworkService.shared.requestBreweryData { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let breweryData):
                    self.breweriesModel = BreweriesModel(breweryData: breweryData)
                    //пишем в кэш полученные данные о пивоварнях
                    do {
                        try DataCache.instance.write(codable: breweryData, forKey: "breweryDataArray")
                    } catch {
                        print(error)
                    }
                case .failure(let requestError):
                    print("Breweries error: \(requestError)")
                    do {
                        let breweryDataFromCache: [BreweryData]? = try DataCache.instance.readCodable(forKey: "breweryDataArray")
                        guard let breweries = breweryDataFromCache else {
                            // здесь обработка ситуации: нет инета и нет ничего в кэше по пивоварням, в .notify не улетаем
                            self.sayAboutInternetError()
                            // если модель пив инициализирована - то надо рисовать UI, а на пивоварни просто в инфо не отображать
                            print("Brewery don't cached")
                            return
                        }
                        self.breweriesModel = BreweriesModel(breweryData: breweries)
                    }
                    catch {
                        print(error.localizedDescription)
                    }
                }
                
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            print("All requests completed")
            // рисуем UI

            let item = self.calendarModel?.getTodayBeer()
            if let item = item {
                self.setUI(beer: item)
            } else {
                self.beerLabelView.backgroundColor = .systemGray
                self.beerNameLabel.text = "Не найдено пиво на текущую дату"
                self.beerNameLabel.alpha = 1
            }
            
            self.activityIndicatorView.stopAnimating()
        }
        
        
    }
    
    func setUI(beer: BeerData) {
        currentBeerID = beer.id ?? 0
        
        if favoriteBeersModel.isCurrentBeerFavorite(id: currentBeerID) {
            addToFavoriteButton.setImage(UIImage(named: "iconLikeFill"), for: .normal)
        } else {
            addToFavoriteButton.setImage(UIImage(named: "iconLikeEmpty"), for: .normal)
        }
        
        // вычисляем светлость фона и в зависимости от этого цвет лейблов и кнопок выставляем
        if let backgroundColor = beer.backgroundColor {
            beerLabelView.backgroundColor = UIColor(hex: backgroundColor)
            if let arrayOfColors = ColorService.shared.getFontColors(backgroundColor: UIColor(hex: backgroundColor)) {
                currentFontColor = arrayOfColors[0] // фиксируем цвет для перекраски кнопок
                beerDateDayLabel.textColor = arrayOfColors[0]
                beerDateMonthLabel.textColor = arrayOfColors[0]
                beerNameLabel.textColor = arrayOfColors[1]
                beerManufacturerLabel.textColor = arrayOfColors[2]
                beerTypeLabel.textColor = arrayOfColors[3]
                // buttons
                addToFavoriteButton.imageView?.setImageColor(color: currentFontColor) // другой метод, тк непонятно какая картинка на кнопке - fill или empty
                setButtonImageColor(button: untappdButton, imageName: "iconUntappdSVG")
                setButtonImageColor(button: infoButton, imageName: "iconInfo")
                setButtonImageColor(button: favoritesButton, imageName: "iconFavoritesSVG")
                setButtonImageColor(button: goToTodayButton, imageName: "iconToday")
                setButtonImageColor(button: shareButton, imageName: "iconShareSVG")
            }
        }
        
        
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
        
        if calendarModel?.currentIndex == calendarModel?.borderIndex {
            goToTodayButton.isEnabled = false
        } else {
            goToTodayButton.isEnabled = true
        }
        
        shareViewModel.currentBeer = beer
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
            dateStackViewTopConstraint.constant = 16
            beerDateDayLabel.font = beerDateDayLabel.font.withSize(48) //64 and 36
            beerDateMonthLabel.font = beerDateDayLabel.font.withSize(22)
            beerInfoStackView.spacing = 4
        case 568...750:
            //print("SE 2th and Plus")
            beerInfoTopConstraint.constant = 12
            dateStackViewTopConstraint.constant = 20
            beerDateDayLabel.font = beerDateDayLabel.font.withSize(56)
            beerDateMonthLabel.font = beerDateMonthLabel.font.withSize(28)
            beerInfoStackView.spacing = 6
        default: break
        }
    }
    
    private func addToFavorites() {
        if favoriteBeersModel.isCurrentBeerFavorite(id: currentBeerID) {
            favoriteBeersModel.removeBeerFromFavorites(id: currentBeerID)
            addToFavoriteButton.setImage(UIImage(named: "iconLikeEmpty"), for: .normal)
            
            setButtonImageColor(button: addToFavoriteButton, imageName: "iconLikeEmpty")
        } else {
            generator.impactOccurred()
            favoriteBeersModel.saveBeerToFavorites(id: currentBeerID)
            addToFavoriteButton.setImage(UIImage(named: "iconLikeFill"), for: .normal)
            
            setButtonImageColor(button: addToFavoriteButton, imageName: "iconLikeFill")
        }
    }
    
    private func setButtonImageColor(button: UIButton, imageName: String) {
        let origImage = UIImage(named: imageName)
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        button.setImage(tintedImage, for: .normal)
        button.tintColor = currentFontColor
    }
    
    @IBAction func untappdButtonTap(_ sender: UIButton) {
        if let calendar = calendarModel {
            let currentBeer = calendar.beers[calendar.currentIndex]
            if let untappdUrl = currentBeer.untappdURL {
                let components = untappdUrl.components(separatedBy: "/")
                
                let urlForUntappd = URL(string: "untappd://beer/\(components.last ?? "0")")! //url format for untappd, scheme "untappd" in info.plist
                if UIApplication.shared.canOpenURL(urlForUntappd) {
                    
                    UIApplication.shared.open(urlForUntappd, options: [:])
                } else {
                    let basicUrl = URL(string: untappdUrl)!
                    if UIApplication.shared.canOpenURL(basicUrl) {
                        UIApplication.shared.open(basicUrl, options: [:])
                    }
                }
                
            }
        }
    }
    
    @IBAction func addToFavoriteButtonTap(_ sender: UIButton) {
        addToFavorites()
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
        if shareViewModel.isViewShowing {
            shareViewModel.hideView()
        } else {
            shareViewModel.showView()
        }
    }
    
    
    @IBAction func goToTodayButtonTap(_ sender: UIButton) {
        goToTodayBeer()
    }
    
    @IBAction func infoButtonTap(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let infoViewController = storyboard.instantiateViewController(identifier: "InfoViewController") as? InfoViewController else {return}
        if let currentBeer = calendarModel?.getBeerForID(id: currentBeerID) {
            infoViewController.currentBeer = currentBeer
            infoViewController.currentBrewery = breweriesModel?.getCurrentBrewery(id: currentBeer.breweryID ?? 0)
            present(infoViewController, animated: true, completion: nil)
        }
        
        
    }
    

}

extension MainViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return PartialSizePresentViewController(presentedViewController: presented, presenting: presenting, withRatio: 0.8)
    }
    
}


//
//  ViewController.swift
//  BeerCalendar
//
//  Created by Yuriy Pashkov on 7/26/21.
//

import UIKit
import Kingfisher
import DataCache
import MarqueeLabel

class MainViewController: UIViewController, MainViewControllerDelegate {
    
    // MARK: - IB Outlets
    @IBOutlet weak var beerLabelView: UIView!
    @IBOutlet weak var beerNameLabel: MarqueeLabel!
    @IBOutlet weak var beerTypeLabel: UILabel!
    @IBOutlet weak var beerLabelImage: UIImageView!
    @IBOutlet weak var beerDateDayLabel: UILabel!
    @IBOutlet weak var beerDateMonthLabel: UILabel!
    @IBOutlet weak var beerManufacturerLabel: MarqueeLabel!
    @IBOutlet weak var beerInfoTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var dateStackViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var beerInfoStackView: UIStackView!
    @IBOutlet weak var addToFavoriteButton: UIButton!
    @IBOutlet weak var favoritesButton: UIButton!
    @IBOutlet weak var untappdButton: UIButton!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var goToTodayButton: UIButton!
    @IBOutlet weak var calendarButton: UIButton!
    @IBOutlet weak var errorButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var errorImageView: UIImageView!
    
    
    
    
    var calendarModel: CalendarModel?
    var breweriesModel: BreweriesModel?
    var messageViewModel: MessageViewModel!
    var newShareViewModel: NewShareViewModel!
    let activityIndicatorView = UIActivityIndicatorView()
    var currentBeerID: String = ""
    var favoriteBeersModel = FavoriteBeersModel()
    var soundService = SoundService() // воспроизведение звуков
    let generator = UIImpactFeedbackGenerator(style: .heavy) // генератор вибрации
    var currentFontColor: UIColor = .black
    var wrongBeerImage: UIImage? = UIImage(named: "wrongBeer")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // view для оповещения пива про следующий день
        messageViewModel = MessageViewModel(x: view.frame.size.width, y: view.frame.size.height, width: view.frame.size.width, height: 100)
        view.addSubview(messageViewModel.messageView)
        
        // view для расшаривания
        let topInset = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0
        let y = shareButton.frame.origin.y + topInset
        newShareViewModel = NewShareViewModel(myFrame: CGRect(x: view.frame.size.width - 155, y: y, width: 144, height: 48), shareButton: shareButton, delegate: self)
        view.addSubview(newShareViewModel)

        addGestures()
        
        prepareUI()

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
                if newShareViewModel.isViewShowing {
                    newShareViewModel.hideView()
                }
                if messageViewModel.isMessageViewShow {
                    messageViewModel.hideMessageView()
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
                messageViewModel.showMessageView(withText: "Следующее пиво можно увидеть только на следующий день.")

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
                if newShareViewModel.isViewShowing {
                    newShareViewModel.hideView()
                }
                if messageViewModel.isMessageViewShow {
                    messageViewModel.hideMessageView()
                }
                UIView.transition(with: beerLabelView,
                                  duration: 0.7,
                                  options: [.transitionCurlDown],
                                  animations: {
                                    self.setUI(beer: previousBeer)
                                  }) { finished in
                    if let calendar = self.calendarModel, calendar.showCrowdFinding() {
                        // показать рекламу
                        self.showCrowdFindingController()
                    }
                }

            default: break
            }
        } else {
            // показываем сообщения, что пиво в этом году закончилось
            if !messageViewModel.isMessageViewShow {
                messageViewModel.showMessageView(withText: "Увы, на предыдущие даты пиво не завезли.")

                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    if self.messageViewModel.isMessageViewShow {
                        self.messageViewModel.hideMessageView()
                    }
                }
                
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
            crowdFindingController.jumpURL = calendar.crowdFindingData?.jumpUrl
            present(crowdFindingController, animated: true, completion: nil)
        }
    }
    
    // два метода для выбора пива после выбора даты, чтобы лишний раз не прятать PickerVIew
    func isBeerExist(date: String) -> Bool {
        if let calendar = calendarModel {
            return calendar.isBeerForDateExist(date: date) ? true : false
        }
        return false
    }
    
    func goToBeerFromDatePicker(date: String) {
        if let beer = calendarModel?.getBeerForDate(date: date) {
            goToChooseneBeer(choosenBeer: beer)
        }
    }
    
    func goToChooseneBeer(choosenBeer: BeerData) {
        // если находимся на нём же, то переворачивать страничку не надо
        guard let id = choosenBeer.id, let calendar = calendarModel, id != currentBeerID else { return }
        //перелистываем страничку
        //обновляем UI
        //устанавливаем currentIndex в модели
        let currentBeer = calendar.getBeerForID(id: currentBeerID)
        if calendar.setCurrentIndexForChoosenFavoriteBeer(beerID: id) {
            soundService.playRandomSound()
            UIView.transition(with: beerLabelView,
                              duration: 0.7,
                              options: calendar.compareTwoBeersDate(beerOne: choosenBeer, beerTwo: currentBeer) ? [.transitionCurlUp] : [.transitionCurlDown],
                              animations: {
                                self.setUI(beer: choosenBeer)
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
                setElementsAlpha(value: 0, valueForImage: 0)
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
    
    private func sayAboutError(text: String) {
        //view.backgroundColor = .systemGray5
        view.layer.sublayers?.forEach({ layer in
            if layer.name == "backgroundColor" {
                layer.removeFromSuperlayer()
            }
        })
        activityIndicatorView.stopAnimating()
        errorButton.layer.cornerRadius = 8
        errorButton.alpha = 1
        errorLabel.alpha = 1
        errorImageView.alpha = 1
        errorLabel.text = "\(text) Попробуйте повторить запрос."
        messageViewModel.isMessageViewShow = true
    }
    
    
    private func loadBeersAndBrewries() {
        prepareBackgroundWhileLoadingData()
        
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
                    //print(requestError)
                    print("Problem with loading beers")
                    do {
                        let beerDataFromCache: [BeerData]? = try DataCache.instance.readCodable(forKey: "beerDataArray")
                        guard let beerData = beerDataFromCache else {
                            // здесь обработка ситуации: нет инета или ошибка декодинга, и нет ничего в кэше по пивам, в .notify не улетаем
                            if requestError as? NetworkError == NetworkError.decodingError {
                                self.sayAboutError(text: "Ошибка декодирования данных по пивам.")
                            } else {
                                self.sayAboutError(text: "Ошибка подключения или проблема с интернетом.")
                            }
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
                    print("Problem with loading breweries")
                    do {
                        let breweryDataFromCache: [BreweryData]? = try DataCache.instance.readCodable(forKey: "breweryDataArray")
                        guard let breweries = breweryDataFromCache else {
                            // здесь обработка ситуации: нет инета или ошибка декодинга, и нет ничего в кэше по пивоварням, в .notify не улетаем
                            if requestError as? NetworkError == NetworkError.decodingError {
                                self.sayAboutError(text: "Ошибка декодирования данных по пивоварням.")
                            } else {
                                self.sayAboutError(text: "Ошибка подключения или проблема с интернетом.")
                            }
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
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else {return}
            print("All requests completed")
            print("Data loaded from \(NetworkConfiguration.shared.apiUrl)")
            // рисуем UI и запускаем таймер на отслеживание смены даты

            let item = self.calendarModel?.getTodayBeer()
            
            TimerManager.shared.startTimer()
            
            if let item = item {
                //create today beer
                self.setUI(beer: item)
                //create manual if first launch
                if LaunchChecker.shared.isShowManual() {
                    self.showManual()
                }

            } else {
                self.view.backgroundColor = .systemGray5
                self.errorLabel.alpha = 1
                self.errorImageView.alpha = 1
                self.errorLabel.text = "Не найдено пиво на текущую дату. Попробуйте зайти в приложение позже."
            }
            
            self.activityIndicatorView.stopAnimating()
        }
        
    }
    
    func showManual() {
        let manual = ShowManual(myFrame: self.view.frame, coordinates: self.beerLabelView.createArrayOfCoordinates(views: [
            self.favoritesButton,
            self.goToTodayButton,
            self.calendarButton,
            self.shareButton,
            self.addToFavoriteButton,
            self.untappdButton,
            self.infoButton
        ]))
        self.view.addSubview(manual)
    }
    
    func setUI(beer: BeerData) {
        currentBeerID = beer.id ?? ""
        
        errorImageView.alpha = 0
        errorLabel.alpha = 0
        errorButton.alpha = 0
        
        if favoriteBeersModel.isCurrentBeerFavorite(id: currentBeerID) {
            addToFavoriteButton.setImage(UIImage(named: "iconLikeVer2"), for: .normal)
        } else {
            addToFavoriteButton.setImage(UIImage(named: "iconLikeEmptyVer2"), for: .normal)
        }

        if let firstColor = beer.firstColor, let secondColor = beer.secondColor {
            beerLabelView.backgroundColor = UIColor.white
            
            ColorService.shared.setGradientBackgroundOnView(view: beerLabelView, firstColor: UIColor(hex: firstColor), secondColor: UIColor(hex: secondColor), cornerRadius: 0)
            newShareViewModel.transform = CGAffineTransform.identity // костыль чтобы правильно красилась вьюха после scale
            ColorService.shared.setGradientBackgroundOnView(view: newShareViewModel, firstColor: UIColor(hex: firstColor), secondColor: UIColor(hex: secondColor), cornerRadius: 16)
        }
        
        beerDateDayLabel.textColor = UIColor.black
        beerDateMonthLabel.textColor = UIColor.black
        beerNameLabel.textColor = UIColor(hex: "#232020")
        beerManufacturerLabel.textColor = UIColor(hex: "#3f3f3f")
        beerTypeLabel.textColor = UIColor(hex:"#464545")
        
        beerNameLabel.text = beer.beerName
        beerTypeLabel.text = "\(beer.beerType ?? "")"
        if let abv = beer.beerABV {
            beerTypeLabel.text! += " · \(abv) ABV"
        }
        if let ibu = beer.beerIBU {
            beerTypeLabel.text! += " · \(ibu) IBU"
        }
        if let id = beer.breweryID, let brewery = breweriesModel?.getCurrentBrewery(id: id) {
            beerManufacturerLabel.text = "\(brewery.breweryName ?? "") · \(brewery.breweryCity ?? "")"
        }
        if let dateArray = beer.getStrDate() {
            beerDateDayLabel.text = dateArray[0]
            beerDateMonthLabel.text = dateArray[1]
        }
        
        // подгрузим обложку пива
        if let strUrl = beer.beerLabelURL, let url = URL(string: strUrl) {
            beerLabelImage.kf.indicatorType = .activity
            beerLabelImage.kf.setImage(with: url, placeholder: nil, options: nil) { result in
                switch result {
                case .success(let image):
                    self.beerLabelImage.contentMode = .scaleAspectFill
                    self.beerLabelImage.image = image.image
                case .failure:
                    self.beerLabelImage.contentMode = .center
                    self.beerLabelImage.image = self.wrongBeerImage
                }
            }
        }
        
        setElementsAlpha(value: 0.8, valueForImage: 1)
        
        // кнопка перехода на сегодняшнюю дату активна/неактивна
        if calendarModel?.currentIndex == CalendarModel.borderIndex {
            goToTodayButton.isEnabled = false
        } else {
            goToTodayButton.isEnabled = true
        }
        
        // выставим в модели вью для расшаривания текущее пиво и пивоварню
        newShareViewModel.currentBeer = beer
        if let id = beer.breweryID {
            newShareViewModel.currentBrewery = breweriesModel?.getCurrentBrewery(id: id)
        }
    }
    
    private func setElementsAlpha(value: CGFloat, valueForImage: CGFloat) {
        addToFavoriteButton.alpha = value
        untappdButton.alpha = value
        favoritesButton.alpha = value
        infoButton.alpha = value
        shareButton.alpha = value
        beerLabelImage.alpha = valueForImage
        beerNameLabel.alpha = value
        beerTypeLabel.alpha = value
        beerManufacturerLabel.alpha = value
        beerDateDayLabel.alpha = value
        beerDateMonthLabel.alpha = value
        goToTodayButton.alpha = value
        calendarButton.alpha = value
    }
    
    private func prepareBackgroundWhileLoadingData() {
        ColorService.shared.setGradientBackgroundOnView(view: view, firstColor: UIColor(hex: "#ffcf0d"), secondColor: UIColor(hex: "#e28123"), cornerRadius: 0)
    }
    
    private func prepareUI() {
        setElementsAlpha(value: 0, valueForImage: 0)
    
        beerNameLabel.type = .leftRight
        beerManufacturerLabel.type = .leftRight
        
        beerLabelImage.layer.shadowColor = UIColor.black.cgColor
        beerLabelImage.layer.shadowRadius = 4.0
        beerLabelImage.layer.shadowOpacity = 1.0
        beerLabelImage.layer.shadowOffset = CGSize(width: 0, height: 0)
        beerLabelImage.layer.masksToBounds = false
        
        activityIndicatorView.center = view.center
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.style = .medium
        activityIndicatorView.color = .white
        view.addSubview(activityIndicatorView)
        
        wrongBeerImage = wrongBeerImage?.resized(toWidth: 130)
        
        switch view.frame.size.height {
        case 0...568:
            //print("SE 1th")
            beerInfoTopConstraint.constant = 16
            dateStackViewTopConstraint.constant = 16
            beerDateDayLabel.font = beerDateDayLabel.font.withSize(56) //64 and 36
            beerDateMonthLabel.font = beerDateDayLabel.font.withSize(22)
            beerInfoStackView.spacing = 6
        case 568...750:
            //print("SE 2th and Plus")
            beerInfoTopConstraint.constant = 24
            dateStackViewTopConstraint.constant = 16
            beerDateDayLabel.font = beerDateDayLabel.font.withSize(68)
            beerDateMonthLabel.font = beerDateMonthLabel.font.withSize(32)
            beerInfoStackView.spacing = 8
        default: break
        }
    }
    
    private func addToFavorites() {
        if favoriteBeersModel.isCurrentBeerFavorite(id: currentBeerID) {
            favoriteBeersModel.removeBeerFromFavorites(id: currentBeerID)
            addToFavoriteButton.setImage(UIImage(named: "iconLikeEmptyVer2"), for: .normal)
        } else {
            if let image = UIImage(named: "whiteStar") {
                beerLabelImage.showDoubleTapArt(imageForShowing: image)
            }
            generator.impactOccurred()
            favoriteBeersModel.saveBeerToFavorites(id: currentBeerID)
            addToFavoriteButton.setImage(UIImage(named: "iconLikeVer2"), for: .normal)
        }
    }
    
//    private func setButtonImageColor(button: UIButton, imageName: String) {
//        let origImage = UIImage(named: imageName)
//        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
//        button.setImage(tintedImage, for: .normal)
//        button.setImage(tintedImage, for: .highlighted)
//        button.tintColor = currentFontColor
//    }
    
    @IBAction func untappdButtonTap(_ sender: UIButton) {
        sender.pressedEffect(scale: 0.9) { [weak self] in
            
            guard let self = self else {return}
            
            if let calendar = self.calendarModel {
                let currentBeer = calendar.beers[calendar.currentIndex]
                if let untappdUrl = currentBeer.untappdURL {
                    let components = untappdUrl.components(separatedBy: "/")
                    
                    guard let urlForUntappd = URL(string: "untappd://beer/\(components.last ?? "0")") else {return} //url format for untappd, scheme "untappd" in info.plist
                    if UIApplication.shared.canOpenURL(urlForUntappd) {
                        
                        UIApplication.shared.open(urlForUntappd, options: [:])
                    } else {
                        guard let basicUrl = URL(string: untappdUrl) else {return}
                        if UIApplication.shared.canOpenURL(basicUrl) {
                            UIApplication.shared.open(basicUrl, options: [:])
                        }
                    }
                    
                }
            }
        }

    }
    
    @IBAction func addToFavoriteButtonTap(_ sender: UIButton) {
        sender.pressedEffectForFavorite()
        addToFavorites()
    }
    
    
    @IBAction func favoritesButtonTap(_ sender: UIButton) {
        sender.pressedEffect(scale: 0.9) { [weak self] in
            
            guard let self = self else {return}
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let favoritesViewController = storyboard.instantiateViewController(identifier: "FavoritesViewController") as? FavoritesViewController else {return}
            favoritesViewController.favoritesBeer = self.calendarModel?.getListOfFavoritesBeers(listOfBeersID: self.favoriteBeersModel.listOfFavoriteBeers) ?? [BeerData]()
            favoritesViewController.delegate = self
            //favoritesViewController.transitioningDelegate = self
            //favoritesViewController.modalPresentationStyle = .custom
            self.present(favoritesViewController, animated: true, completion: nil)
        }

    }
    
    
    @IBAction func shareButtonTap(_ sender: UIButton) {
        if newShareViewModel.isViewShowing {
            newShareViewModel.hideView()
        } else {
            newShareViewModel.showView()
        }
    }
    
    let datePicker = UIDatePicker()
    
    @IBAction func goToTodayButtonTap(_ sender: UIButton) {
        sender.pressedEffect(scale: 0.9) { [weak self] in
            self?.goToTodayBeer()
        }
    }
    
    
    @IBAction func calendarButtonTap(_ sender: UIButton) {
        sender.pressedEffect(scale: 0.9) { [weak self] in
            guard let self = self else {return}

            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let datePickerViewController = storyboard.instantiateViewController(identifier: "DatePickerViewController") as? DatePickerViewController else {return}
            datePickerViewController.delegate = self
            datePickerViewController.modalPresentationStyle = .overCurrentContext
            self.present(datePickerViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func infoButtonTap(_ sender: UIButton) {
        sender.pressedEffect(scale: 0.9) { [weak self] in
            
            guard let self = self else {return}
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let infoViewController = storyboard.instantiateViewController(identifier: "InfoViewController") as? InfoViewController else {return}
            if let currentBeer = self.calendarModel?.getBeerForID(id: self.currentBeerID) {
                infoViewController.currentBeer = currentBeer
                infoViewController.currentBrewery = self.breweriesModel?.getCurrentBrewery(id: currentBeer.breweryID ?? 0)
                self.present(infoViewController, animated: true, completion: nil)
            }
        }

    }
    
    @IBAction func errorButtonTap(_ sender: UIButton) {
        errorButton.alpha = 0
        errorLabel.alpha = 0
        errorImageView.alpha = 0
        loadBeersAndBrewries()
    }
    
}

//extension MainViewController: UIViewControllerTransitioningDelegate {
//    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
//        return PartialSizePresentViewController(presentedViewController: presented, presenting: presenting, withRatio: 0.35)
//    }
//}




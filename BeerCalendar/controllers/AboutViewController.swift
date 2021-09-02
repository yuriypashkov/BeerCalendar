//
//  AboutViewController.swift
//  BeerCalendar
//
//  Created by Yuriy Pashkov on 9/2/21.
//

import UIKit
import MessageUI

class AboutViewController: UIViewController, MFMailComposeViewControllerDelegate {

    var currentBeer: BeerData?
    @IBOutlet weak var mainSubview: UIView!
    @IBOutlet weak var feedBackButton: UIButton!
    @IBOutlet weak var rateButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.4) {
            self.mainSubview.alpha = 1
        }
    }
    
    private func setUI() {
        mainSubview.alpha = 0
        guard let currentBeer = currentBeer, let firstColorStr = currentBeer.firstColor, let secondColorStr = currentBeer.secondColor else {return}
        ColorService.shared.setGradientBackgroundOnView(view: view, firstColor: UIColor(hex: firstColorStr), secondColor: UIColor(hex: secondColorStr), cornerRadius: 0)
        feedBackButton.layer.cornerRadius = 12
        feedBackButton.layer.borderWidth = 3
        feedBackButton.layer.borderColor = UIColor.black.cgColor
        rateButton.layer.cornerRadius = 12
        rateButton.layer.borderWidth = 3
        rateButton.layer.borderColor = UIColor.black.cgColor
        
    }
    
    private func sendEmail() {
        let mail = MFMailComposeViewController()
        let osVersion = UIDevice.current.systemVersion
        mail.mailComposeDelegate = self
        mail.setToRecipients(["sshmyt@mail.ru"])
        mail.setSubject("Сообщение из приложения Пивной Календарь")
        mail.setMessageBody("Версия iOS: \(osVersion)</p><p>Напишите что-нибудь:</p><br><br><br><br>", isHTML: true)
        present(mail, animated: true, completion: nil)
    }
    
    @IBAction func feedBackButtonTap(_ sender: UIButton) {
        sender.pressedEffect(scale: 0.96) { [weak self] in
            if MFMailComposeViewController.canSendMail() {
                self?.sendEmail()
            }
        }
    }
    
    @IBAction func rateButtonTap(_ sender: UIButton) {
        sender.pressedEffect(scale: 0.96) {
            if let url = URL(string: "https://apps.apple.com/ru/app/id1581340486"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}

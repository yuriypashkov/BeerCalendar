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
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var stepanLabel: UILabel!
    @IBOutlet weak var yuriyLabel: UILabel!
    @IBOutlet weak var warnLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var instaBeerLabel: UILabel!
    
    var delegate: MainViewControllerDelegate?
    
    
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

        aboutLabel.textAlignment = .justified
        let text = "Приложение <span class='bld'>Пивной Календарь</span> разработано коллаборацией талантов <span class='bld'>Чугуниевая Долина</span>, дабы каждый имел возможность узнавать о новых сортах пенного напитка каждый день. Бумажную версию календаря можно заказать на <span class='bld'>Boomstarter</span>.<br><br>Все этикетки используются с разрешения и одобрения пивоварен. Отдельное спасибо <span class='bld'>Groteskly Yours Studio</span> за использованный в приложении шрифт Okta Neue.<br><br>По вопросам сотрудничества:"

        aboutLabel.attributedText = NSAttributedString(html: text, fontName: "OktaNeue-Regular", fontSize: 16)
        
        
        let stepanText = "<span class = 'half'><span class='bld'>Степан Шмытинский</span><br>Идеи, продюссер</span>"
        let yuriyText = "<span class = 'half'><span class='bld'>Юрий Пашков</span><br>Идеи, программист</span>"
        let instaBeerText = "<span class = 'half'><span class='bld'>Пивной календарь</span><br>Глянуть в Instagram</span>"
        instaBeerLabel.attributedText = NSAttributedString(html: instaBeerText, fontName: "OktaNeue-Regular", fontSize: 15)
        stepanLabel.attributedText = NSAttributedString(html: stepanText, fontName: "OktaNeue-Regular", fontSize: 15)
        yuriyLabel.attributedText = NSAttributedString(html: yuriyText, fontName: "OktaNeue-Regular", fontSize: 15)
        let warnText = "<center>Всё это бесконечно весело, но помните:<br><span class = 'bld'>Чрезмерное употребление алкоголя может навредить вашему здоровью!</span></center>"
        warnLabel.attributedText = NSAttributedString(html: warnText, fontName: "OktaNeue-Regular", fontSize: 16)
        
        let emailLabelText = "<span class = 'half'><span class='bld'>Электропочта</span><br>По любым вопросам</span>"
        emailLabel.attributedText = NSAttributedString(html: emailLabelText, fontName: "OktaNeue-Regular", fontSize: 15)
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
    
    
    @IBAction func emailButtonTap(_ sender: UIButton) {
        sender.pressedEffect(scale: 0.96) { [weak self] in
            if MFMailComposeViewController.canSendMail() {
                self?.sendEmail()
            }
        }
    }
    
    @IBAction func helpButtonTap(_ sender: UIButton) {
        sender.pressedEffect(scale: 0.96) { [weak self] in
            self?.dismiss(animated: true) {
                // show manual
                self?.delegate?.showManual()
            }
        }
    }
    
    @IBAction func instaBeerTap(_ sender: UIButton) {
        sender.pressedEffect(scale: 0.9) {
            if let url = URL(string: "https://www.instagram.com/beer.calendar/"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    @IBAction func stepanButtonTap(_ sender: UIButton) {
        sender.pressedEffect(scale: 0.9) {
            if let url = URL(string: "https://www.instagram.com/misserchmitt/"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    
    @IBAction func yuriyButtonTap(_ sender: UIButton) {
        sender.pressedEffect(scale: 0.9) {
            if let url = URL(string: "https://www.github.com/yuriypashkov/"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}

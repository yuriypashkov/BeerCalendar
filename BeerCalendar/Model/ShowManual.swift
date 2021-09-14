//
//  ShowManual.swift
//  BeerCalendar
//
//  Created by Yuriy Pashkov on 9/7/21.
//

import Foundation
import UIKit

class ShowManual: UIView {
    
    init(myFrame: CGRect, coordinates: [CGRect]) {
        super.init(frame: myFrame)
        backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        // рисуем кружочки
        for i in 1...coordinates.count {
            let frame = coordinates[i-1]
            createRoundWithNumber(origin: frame.origin, width: frame.size.width, number: i)
        }
        
        var fontSize: Int = 14
        var margin = "<br><br><br>"
        // iphone SE
        if myFrame.size.height > 0, myFrame.size.height <= 568  {
            fontSize = 12
            margin = "<br><br>"
        }
        
        // рисуем надписи
        let firstText = "Привет! Ты попал в Пивной Календарь! Здесь каждый день и круглый год тебя ожидает новое пиво! Вот что здесь к чему:"
        createLabel(frame: CGRect(x: myFrame.size.width / 16, y: coordinates[0].origin.y + 32, width: 7 * myFrame.size.width / 8, height: 100), text: firstText, alignment: .left, fontSize: fontSize)
        // список
        let secondText = """
            \(margin)
            1. Избранное/список покупок;<br>
            2. Вернуться на сегодня;<br>
            3. Выбрать дату;<br>
            4. Другое:<br>
                - Поделиться в Instagram;<br>
                - Рассказать друзьям;<br>
                - Информация и обратная связь;<br>
            5. Добавить в избранное;<br>
            6. Открыть Untappd по пиву;<br>
            7. Подробнее о пиве и дате;<br>
                        <br>
                        <br>
            Приятно отдохнуть и узнать много нового!
            """
        createLabel(frame: CGRect(x: myFrame.size.width / 16, y: coordinates[0].origin.y + 72, width: 7 * myFrame.size.width / 8, height: 300), text: secondText, alignment: .left, fontSize: fontSize)
        
        // рисуем надпись Кликни для продолжения
        createLabel(frame: CGRect(x: 0, y: myFrame.size.height / 1.2, width: myFrame.size.width, height: 40), text: "Нажми для продолжения", alignment: .center, fontSize: fontSize)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapOnImage))
        addGestureRecognizer(tapGesture)
    }
    
    @objc func tapOnImage() {
        removeFromSuperview()
    }
    
    private func createLabel(frame: CGRect, text: String, alignment: NSTextAlignment, fontSize: Int) {
        let label = UILabel(frame: frame)
        label.attributedText = NSAttributedString(html: "<span class='half'>\(text.uppercased())</span>", fontName: "OktaNeue-SemiBold", fontSize: fontSize)
        
        label.numberOfLines = 0
        label.textAlignment = alignment
        label.textColor = .white
        //label.font = UIFont(name: "OktaNeue-SemiBold", size: 14)
        self.addSubview(label)
    }
    
    private func createRoundWithNumber(origin: CGPoint, width: CGFloat, number: Int) {
        // рисуем кружок
        let roundPath = UIBezierPath(ovalIn: CGRect(origin: origin, size: CGSize(width: width, height: width)))
        let roundLayer = CAShapeLayer()
        roundLayer.path = roundPath.cgPath
        roundLayer.strokeColor = UIColor.white.cgColor
        roundLayer.fillColor = UIColor.clear.cgColor
        roundLayer.borderWidth = 15
        self.layer.addSublayer(roundLayer)
        // рисуем надпись в кружке
        let label = UILabel(frame: CGRect(x: origin.x, y: origin.y + 2, width: width, height: width))
        label.text = "\(number)"
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont(name: "OktaNeue-SemiBold", size: 18)
        self.addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class LaunchChecker {
    static let shared = LaunchChecker()
    
    func isShowManual() -> Bool {
        let defaults = UserDefaults.standard
        let value = defaults.bool(forKey: "isFirstLaunch")
        if !value {
            defaults.set(true, forKey: "isFirstLaunch")
            return true
        }
        return false
    }
}

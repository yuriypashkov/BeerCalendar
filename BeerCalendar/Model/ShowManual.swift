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
        
        // рисуем надписи
        let firstText = "Привет! Ты попал в Пивной Календарь! Здесь каждый день и круглый год тебя ожидает новое пиво! Вот что здесь к чему:"
        createLabel(frame: CGRect(x: myFrame.size.width / 16, y: coordinates[0].origin.y + 32, width: 7 * myFrame.size.width / 8, height: 100), text: firstText, alignment: .left)
        // список
        let secondText = """
            1. Избранное/список покупок
            2. Вернуться на сегодня
            3. Выбрать дату
            4. Другое
                - Поделиться в Instagram
                - Рассказать друзьям
                - Информация и обратная связь
            5. Добавить в избранное
            6. Открыть Untappd по пиву
            7. Подробнее о пиве
            
            Приятно отдохнуть и узнать много нового!
            """
        createLabel(frame: CGRect(x: myFrame.size.width / 16, y: coordinates[0].origin.y + 72, width: 7 * myFrame.size.width / 8, height: myFrame.size.height / 2), text: secondText, alignment: .left)
        
        // рисуем надпись Кликни для продолжения
        createLabel(frame: CGRect(x: 0, y: myFrame.size.height / 1.2, width: myFrame.size.width, height: 40), text: "Нажми для продолжения", alignment: .center)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapOnImage))
        addGestureRecognizer(tapGesture)
    }
    
    @objc func tapOnImage() {
        removeFromSuperview()
    }
    
    private func createLabel(frame: CGRect, text: String, alignment: NSTextAlignment) {
        let label = UILabel(frame: frame)
        label.text = text.uppercased()
        //label.backgroundColor = .orange
        
        label.numberOfLines = 0
        label.textAlignment = alignment
        label.textColor = .white
        label.font = UIFont(name: "OktaNeue-SemiBold", size: 14)
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

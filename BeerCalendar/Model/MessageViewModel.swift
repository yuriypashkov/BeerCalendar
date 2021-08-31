//
//  MessageViewModel.swift
//  BeerCalendar
//
//  Created by Yuriy Pashkov on 8/3/21.
//

import Foundation
import UIKit

class MessageViewModel {
    
    var messageView = UIView()
    var isMessageViewShow = false
    private var x: CGFloat
    private var y: CGFloat
    private var width: CGFloat
    private var height: CGFloat
    
    init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) { // инициализируем класс с view.frame.size
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        messageView = UIView(frame: CGRect(x: 0.15 * x, y: y, width: 0.7 * width, height: height))
        messageView.backgroundColor = .systemGreen
        messageView.layer.cornerRadius = 30
        let label = UILabel(frame: CGRect(x: 0, y: 8, width: messageView.frame.size.width - 32, height: height))
        label.center = CGPoint(x: messageView.frame.size.width / 2 + 0.05 * x, y: 50)
        label.textAlignment = .center
        label.textColor = .white
        label.numberOfLines = 0
        label.font = UIFont(name: "OktaNeue-Medium", size: 16)
        label.text = "Следующее пиво можно увидеть только на следующий день."
        messageView.addSubview(label)
    }
    
    func showMessageView() {
        UIView.animate(withDuration: 0.8,
                       delay: 0,
                       usingSpringWithDamping: 0.1,
                       initialSpringVelocity: 1,
                       options: .curveEaseInOut, animations: {
                        self.messageView.frame = CGRect(x: 0.1 * self.x, y: self.y - 90, width: 0.8 * self.width, height: self.height + 20) // 0.1 0.8
                       }, completion: { finished in
                        self.isMessageViewShow.toggle()
                       })
    }
    
    func hideMessageView() {
        UIView.animate(withDuration: 0.3) {
            self.messageView.frame = CGRect(x: 0.15 * self.x, y: self.y, width: 0.7 * self.width, height: self.height) // 0.15 0.7
        } completion: { finished in
            self.isMessageViewShow.toggle()
        }
    }
    
}


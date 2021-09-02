//
//  DatePickerViewController.swift
//  BeerCalendar
//
//  Created by Yuriy Pashkov on 8/30/21.
//

import UIKit

class DatePickerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var pickerDaysYear = [
        ["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31"],
        ["Январь","Февраль","Март","Апрель","Май","Июнь","Июль","Август","Сентябрь","Октябрь","Ноябрь","Декабрь"]
    ]
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }

    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        switch component {
        case 0:
            return 40
        default:
            return 130
        }
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDaysYear[component].count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDaysYear[component][row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let strDay = pickerDaysYear[0][pickerView.selectedRow(inComponent: 0)]
        let strMonth = pickerDaysYear[1][pickerView.selectedRow(inComponent: 1)]
        
        switch isPickerViewValueValid(strDay: strDay, strMonth: strMonth) {
        case .afterTodayDate:
            pickerView.selectRow(dayIndex, inComponent: 0, animated: true)
            pickerView.selectRow(monthIndex, inComponent: 1, animated: true)
        case .wrongDate:
            pickerView.selectRow(DateValidator.shared.returnLastDayForMonth(month: strMonth) - 1, inComponent: 0, animated: true)
        case .normalDate:
            ()
        }


    }
    

    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var mainSubview: UIView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    
    var delegate: MainViewControllerDelegate?
    
    // индексы для ограничения выбора даты
    private var dayIndex: Int = 1
    private var monthIndex: Int = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        setUI()
        setGestures()
    }
    
    @objc func tapOnView() {
        UIView.animate(withDuration: 0.5) {
            self.view.frame.origin = CGPoint(x: self.view.frame.origin.x, y: self.view.frame.origin.y + 100)
        } completion: { finished in
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func isPickerViewValueValid(strDay: String, strMonth: String) -> DateValid {
        
        // проверим чтобы выбираемая дата не была больше текущей
        var intMonth = 0
        let months = pickerDaysYear[1]
        
        for i in 0..<months.count {
            if months[i] == strMonth {
                intMonth = i
                break
            }
        }
        
        if let intDay = Int(strDay) {
            if intMonth > monthIndex || (intDay > dayIndex + 1 && intMonth == monthIndex) {
                
                return .afterTodayDate
            }
        }
        // проверим получаемую дату на валидность
        if let intDay = Int(strDay), !DateValidator.shared.isDateValid(day: intDay, month: strMonth) {
            return .wrongDate
        }
        
        return .normalDate
    }
    
    private func setUI() {
        errorLabel.alpha = 0
        mainSubview.layer.cornerRadius = 16
        mainSubview.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        doneButton.layer.cornerRadius = 8
        // выставим пикервью на сегодняшнюю дату
        let date = Date()
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.day, .month], from: date)
        if let day = dateComponents.day, let month = dateComponents.month {
            dayIndex = day - 1
            monthIndex = month - 1
            pickerView.selectRow(dayIndex, inComponent: 0, animated: false)
            pickerView.selectRow(monthIndex, inComponent: 1, animated: false)
        }
    }
    
    private func setGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapOnView))
        view.addGestureRecognizer(tapGesture)
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(tapOnView))
        swipeGesture.direction = .down
        mainSubview.addGestureRecognizer(swipeGesture)
    }
    
    private func showErrorLabel(text: String) {
        self.errorLabel.alpha = 1
        self.errorLabel.text = text
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.errorLabel.alpha = 0
        }
    }
    
    @IBAction func doneButtonTap(_ sender: UIButton) {
        sender.pressedEffect(scale: 0.96) { [weak self] in
            guard let self = self else {return}
            let date = Date()
            let calendar = Calendar.current
            let dateComponents = calendar.dateComponents([.year], from: date)
            
            let dayIndex = self.pickerView.selectedRow(inComponent: 0)
            let strDay = self.pickerDaysYear[0][dayIndex]
            let monthIndex = self.pickerView.selectedRow(inComponent: 1)
            let strMonth = self.pickerDaysYear[1][monthIndex]
            
            switch self.isPickerViewValueValid(strDay: strDay, strMonth: strMonth) {
            case .afterTodayDate:
                self.showErrorLabel(text: "Выбранная дата пока что недоступна")
            case .wrongDate:
                self.showErrorLabel(text: "Выбранной даты не существует")
            case .normalDate:
                let resultDate = "\(dayIndex + 1).\(monthIndex + 1).\(dateComponents.year ?? 0)"
                
                if let delegate = self.delegate, delegate.isBeerExist(date: resultDate) {
                    self.dismiss(animated: true) {
                        delegate.goToBeerFromDatePicker(date: resultDate)
                    }
                } else {
                    let alert = AlertManager.shared.createAlert(title: "Ошибочка вышла", text: "Пиво на выбранную дату не найдено")
                    self.present(alert, animated: true, completion: nil)
                }

            }
        }
    }
    
}


enum DateValid {
    case wrongDate
    case normalDate
    case afterTodayDate
}

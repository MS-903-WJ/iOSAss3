//
//  ViewController.swift
//  iOSAss3
//
//  Created by John Wang on 2/5/2023.
//

import Foundation
import RealmSwift
import UIKit

class AddController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var transferView: UIView!
    @IBOutlet var incomeView: UIView!
    @IBOutlet var expenseView: UIView!
    
    @IBOutlet var giftButton: UIButton!
    @IBOutlet var wageButton: UIButton!
    @IBOutlet var educationButton: UIButton!
    @IBOutlet var medicalButton: UIButton!
    @IBOutlet var transportationButton: UIButton!
    @IBOutlet var houdingButton: UIButton!
    @IBOutlet var clothingButton: UIButton!
    @IBOutlet var foodButton: UIButton!
    
    @IBOutlet var equalButton: UIButton!
    @IBOutlet var subButton: UIButton!
    @IBOutlet var addButton: UIButton!
    @IBOutlet var nineButton: UIButton!
    @IBOutlet var eightButton: UIButton!
    @IBOutlet var sevenButton: UIButton!
    @IBOutlet var sixButton: UIButton!
    @IBOutlet var fiveButton: UIButton!
    @IBOutlet var fourButton: UIButton!
    @IBOutlet var threeButton: UIButton!
    @IBOutlet var twoButton: UIButton!
    @IBOutlet var oneButton: UIButton!
    @IBOutlet var deleteButton: UIButton!
    @IBOutlet var zeroButton: UIButton!
    @IBOutlet var pointButton: UIButton!
    
    @IBOutlet var notesTextField: UITextField!
    @IBOutlet var moneyLabel: UILabel!
    
    @IBOutlet var accountButton: UIButton!
    @IBOutlet var accountPicker: UIPickerView!

    @IBOutlet var dateButton: UIButton!
    @IBOutlet var datePicker: UIDatePicker!
    
    var selectedButton: UIButton?
    
    var selectedButtonInfo: String?
    
    let moneyLabelState: String = "0.00"
    
    var equalButtonState: Bool = false
    var operaCount: Int = 0
    var overlayView: UIView!
    
    var currentSegment: String = "expense"

    var accounts: Results<Account>!
    let gradientLayer = CAGradientLayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        educationButton.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)
        medicalButton.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)
        transportationButton.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)
        houdingButton.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)
        clothingButton.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)
        foodButton.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)
        wageButton.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)
        giftButton.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)
        
        foodButton.backgroundColor = UIColor(red: 0.6, green: 0.8, blue: 1.0, alpha: 0.7)
        foodButton.layer.cornerRadius = foodButton.frame.size.height / 2
        foodButton.clipsToBounds = true
        selectedButton = foodButton
        selectedButtonInfo = "Food"
        selectedButtonInfo = foodButton.titleLabel?.text
        
        let numberButtons = [oneButton, twoButton, threeButton, fourButton, fiveButton, sixButton, sevenButton, eightButton, nineButton, zeroButton]
        for button in numberButtons {
            button?.addTarget(self, action: #selector(numberButtonClicked(_:)), for: .touchUpInside)
        }

        let operationButtons = [equalButton, subButton, addButton]
        for button in operationButtons {
            button?.addTarget(self, action: #selector(operationButtonClicked(_:)), for: .touchUpInside)
        }

        deleteButton.addTarget(self, action: #selector(deleteButtonClicked(_:)), for: .touchUpInside)
        pointButton.addTarget(self, action: #selector(pointButtonClicked(_:)), for: .touchUpInside)
        equalButton.addTarget(self, action: #selector(equalButtonClicked(_:)), for: .touchUpInside)
        moneyLabel.text = moneyLabelState
        
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        datePicker.isHidden = true

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateButton.setTitle(dateFormatter.string(from: Date()), for: .normal)
        dateButton.addTarget(self, action: #selector(dateButtonClicked(_:)), for: .touchUpInside)
        
        datePicker.backgroundColor = UIColor.systemGray6
        dateButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        // 创建一个透明的覆盖视图，用于捕捉点击事件
        overlayView = UIView(frame: view.bounds)
        overlayView.backgroundColor = UIColor.clear
        overlayView.isHidden = true
        view.addSubview(overlayView)

        // 将 datePicker 添加到覆盖视图上
        view.addSubview(datePicker)
        view.addSubview(accountPicker)

        // 为覆盖视图添加点击手势识别器
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(overlayViewTapped))
        overlayView.addGestureRecognizer(tapGestureRecognizer)
        // 为覆盖视图添加点击手势识别器
        let tapGestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(overlayViewTapped2))
        overlayView.addGestureRecognizer(tapGestureRecognizer)
        
        expenseView.isHidden = false
        incomeView.isHidden = true
        transferView.isHidden = true
        
        accountPicker.isHidden = true
        accountPicker.dataSource = self
        accountPicker.delegate = self
        
        // 设置渐变颜色
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.white.cgColor,
            UIColor.white.cgColor,
            UIColor.clear.cgColor
        ]
        
        // 设置开始和结束的位置
        gradientLayer.locations = [0, 0.4, 0.6, 1]
        
        // 设置渐变的方向（从上到下）
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        
        // 设置渐变层的大小
        gradientLayer.frame = accountPicker.bounds
        
        // 将渐变层添加到accountPicker的背景
        accountPicker.layer.mask = gradientLayer

        let realm = try! Realm()
        accounts = realm.objects(Account.self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = accountPicker.bounds
    }

    // UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return accounts.count
    }

    // UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return accounts[row].name
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        accountButton.setTitle(accounts[row].name, for: .normal)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if accountPicker.isHidden == false {
            accountPicker.isHidden = true
        }
    }
    
    @IBAction func accountButtonTapped(_ sender: UIButton) {
        accountPicker.isHidden = !accountPicker.isHidden
        overlayView.isHidden = !overlayView.isHidden
        if !overlayView.isHidden {
            // 将 overlayView 移到 accountPicker 的下方
            view.insertSubview(overlayView, belowSubview: accountPicker)
        }
    }
    
    @objc func buttonClicked(_ sender: UIButton) {
        // 取消上一个按钮的背景颜色
        selectedButton?.backgroundColor = nil
        selectedButton?.layer.cornerRadius = 0.0 // reset the cornerRadius
        
        // 设置新的按钮的背景颜色
        sender.backgroundColor = randomGradientColor()
        
        // 使按钮呈现圆形
        sender.layer.cornerRadius = sender.frame.size.height / 2
        sender.clipsToBounds = true // This will make sure the button is clipped to a round shape
        
        // 保存当前选中的按钮和按钮信息
        selectedButton = sender
        if let categoryLabel = sender.superview?.viewWithTag(200) as? UILabel {
            // 获取标签的文本并保存到 selectedButtonInfo
            selectedButtonInfo = categoryLabel.text
        }
    }

    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        expenseView.isHidden = true
        incomeView.isHidden = true
        transferView.isHidden = true
        switch sender.selectedSegmentIndex {
        case 0:
            expenseView.isHidden = false
            buttonClicked(foodButton)
            currentSegment = "expense"
            moneyLabel.text = moneyLabelState
        case 1:
            incomeView.isHidden = false
            buttonClicked(wageButton)
            currentSegment = "income"
            moneyLabel.text = moneyLabelState
        case 2:
            transferView.isHidden = false
            currentSegment = "transfer"
            moneyLabel.text = moneyLabelState
        default:
            break
        }
    }
    
    @objc func numberButtonClicked(_ sender: UIButton) {
        let value = sender.titleLabel?.text ?? ""
        updateMoneyLabel(with: value)
        updateEqualButtonTitle()
    }

    @objc func operationButtonClicked(_ sender: UIButton) {
        let value = sender.titleLabel?.text ?? ""
        updateMoneyLabel(with: value)
        updateEqualButtonTitle()
    }
    
    @objc func equalButtonClicked(_ sender: UIButton) {
        if sender.titleLabel?.text == "SAVE" {
            // 打印被点击的分类按钮值信息，note text field信息和money label信息
            print("Current Segment: \(currentSegment)")
            print("Selected Category: \(selectedButtonInfo ?? "Food")")
            print("Note: \(notesTextField.text ?? "No Note")")
            print("Amount: \(moneyLabel.text ?? "0.00")")
            print("Account:\(String(accountButton.title(for: .normal) ?? "no account"))")
            let transaction = Transaction()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy"
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

            if let dateTitle = dateButton.title(for: .normal),
               let date = dateFormatter.date(from: dateTitle)
            {
                // 获取当前时间的时分秒
                let now = Date()
                let calendar = Calendar.current
                let hour = calendar.component(.hour, from: now)
                let minute = calendar.component(.minute, from: now)
                let second = calendar.component(.second, from: now)

                // 将时分秒添加到用户选择的日期
                var dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
                dateComponents.hour = hour
                dateComponents.minute = minute
                dateComponents.second = second

                if let combinedDate = calendar.date(from: dateComponents) {
                    print(dateTitle)
                    print(combinedDate)
                    transaction.date = combinedDate
                } else {
                    let defaultDateString = "May 15, 2023"
                    transaction.date = dateFormatter.date(from: defaultDateString) ?? Date()
                }
            } else {
                let defaultDateString = "May 15, 2023"
                transaction.date = dateFormatter.date(from: defaultDateString) ?? Date()
            }

            transaction.transactionType = "\(currentSegment)"
            if currentSegment == "income" {
                transaction.incomeSource = accountButton.title(for: .normal) ?? "default"
                transaction.expenseSource = nil
            } else {
                transaction.expenseSource = accountButton.title(for: .normal) ?? "default"
                transaction.incomeSource = nil
            }
            
            let amount = Double(moneyLabel.text ?? "") ?? 0.00
            transaction.amount = amount

            transaction.expenseCategory = selectedButtonInfo ?? "Food"
            transaction.note = notesTextField.text ?? "No Note"
            
            do {
                let realm = try Realm()
                try realm.write {
                    realm.add(transaction)
                }
            } catch {
                print("Error writing to realm: \(error)")
            }
            
            let accountName = accountButton.title(for: .normal) ?? "default"
            updateAccountBalance(accountName: accountName, transaction: transaction)
            
            // 返回上一页
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadTableView"), object: nil)
            
            dismiss(animated: true, completion: nil)
        } else {
            // 执行计算操作
            if let calculate = moneyLabel.text {
                let re = calculateExpression(calculate)
                moneyLabel.text = re

                // 更改等号按钮标题为 "SAVE"
                equalButton.setTitle("SAVE", for: .normal)
            }
        }
    }

    @objc func deleteButtonClicked(_ sender: UIButton) {
        if let currentText = moneyLabel.text, !currentText.isEmpty {
            moneyLabel.text = String(currentText.dropLast())
            if moneyLabel.text!.isEmpty {
                moneyLabel.text = moneyLabelState
            }
        }
        updateEqualButtonTitle()
    }

    @objc func pointButtonClicked(_ sender: UIButton) {
        let value = sender.titleLabel?.text ?? ""
        updateMoneyLabel(with: value)
    }
    
    func updateEqualButtonTitle() {
        if let expression = moneyLabel.text, let _ = calculateExpression(expression) {
            equalButton.setTitle("=", for: .normal)
        } else {
            equalButton.setTitle("SAVE", for: .normal)
        }
    }
    
    func updateMoneyLabel(with value: String) {
        if value != "=" && value != "SAVE" {
            if let lastCharacter = moneyLabel.text?.last {
                if moneyLabel.text == moneyLabelState {
                    if let number = Float(value), number.isFinite || value == "." {
                        moneyLabel.text = value
                    }
                } else {
                    if let firstCharacter = value.first {
                        if firstCharacter.isNumber {
                            moneyLabel.text = moneyLabel.text! + value
                        } else if value == "." {
                            // 获取最后一个运算符的位置
                            var lastOperatorIndex: String.Index?
                            for (index, char) in moneyLabel.text!.enumerated() {
                                if !char.isNumber && char != "." {
                                    lastOperatorIndex = moneyLabel.text!.index(moneyLabel.text!.startIndex, offsetBy: index)
                                }
                            }
                            
                            // 获取当前操作数
                            let currentOperand: String
                            if let lastOperatorIndex = lastOperatorIndex {
                                currentOperand = String(moneyLabel.text![moneyLabel.text!.index(after: lastOperatorIndex)...])
                            } else {
                                currentOperand = moneyLabel.text!
                            }
                            
                            // 检查当前操作数是否已存在有效的小数点
                            if !currentOperand.contains(".") {
                                moneyLabel.text = moneyLabel.text! + value
                            }
                        } else {
                            // 检查并替换已有的运算符
                            if lastCharacter.isNumber {
                                // 查找第一个运算符
                                var operatorFound: Character?
                                for char in moneyLabel.text! {
                                    if !char.isNumber && char != "." {
                                        operatorFound = char
                                        break
                                    }
                                }
                                
                                if let operatorFound = operatorFound {
                                    // 检查是否满足两个数字和一个运算符的条件
                                    let components = moneyLabel.text!.split(separator: operatorFound)
                                    if components.count == 2 {
                                        if let calculate = moneyLabel.text {
                                            let re = calculateExpression(calculate)
                                            moneyLabel.text = re
                                            moneyLabel.text = moneyLabel.text! + value
                                        }
                                    } else {
                                        moneyLabel.text = moneyLabel.text! + value
                                    }
                                } else {
                                    moneyLabel.text = moneyLabel.text! + value
                                }
                            } else {
                                moneyLabel.text?.removeLast()
                                moneyLabel.text = moneyLabel.text! + value
                            }
                        }
                    }
                }
            }
            updateEqualButtonTitle()
        }
    }

    func calculateExpression(_ inputString: String) -> String? {
        // 匹配操作数和操作符的正则表达式
        let pattern = "([-+]?\\d*\\.?\\d+|[+-])"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])

        // 将操作数和操作符存储在数组中
        let matches = regex.matches(in: inputString, options: [], range: NSRange(location: 0, length: inputString.count))
        var components: [String] = []
        for match in matches {
            for i in 0 ..< match.numberOfRanges {
                let range = match.range(at: i)
                let matchString = (inputString as NSString).substring(with: range)
                components.append(matchString)
            }
        }

        // 检查数组中是否有至少两个操作数和一个操作符
        if components.count < 3 {
            print("Invalid input string format")
            return nil
        }

        // 提取操作数和操作符
        guard let firstNumber = Decimal(string: components[0]),
              let secondNumber = Decimal(string: components[2])
        else {
            print("Invalid numbers in input string")
            return nil
        }
        let operation = components[1]

        // 根据操作符执行相应的操作
        let result: Decimal
        if operation == "+" {
            result = firstNumber - secondNumber
        } else {
            result = firstNumber + secondNumber
        }
        print("结果为：\(result)")

        return "\(result)"
    }
    
    @objc func dateButtonClicked(_ sender: UIButton) {
        datePicker.isHidden = !datePicker.isHidden
        overlayView.isHidden = !overlayView.isHidden
        if !overlayView.isHidden {
            // 将 overlayView 移到 datePicker 的下方
            view.insertSubview(overlayView, belowSubview: datePicker)
        }
    }

    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateButton.setTitle(dateFormatter.string(from: sender.date), for: .normal)
        dateButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
    }
    
    @objc func handleTapOutsideDatePicker(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: view)

        // 如果点击位置在 datePicker 之外，隐藏 datePicker
        if datePicker.isHidden == false {
            if !datePicker.frame.contains(location) {
                datePicker.isHidden = true
                view.alpha = 1.0
                view.isUserInteractionEnabled = true
            }
        } else {
            if !accountPicker.frame.contains(location) {
                accountPicker.isHidden = true
                view.alpha = 1.0
                view.isUserInteractionEnabled = true
            }
        }
    }
    
    func setInteractionEnabledForAllSubviews(in view: UIView, enabled: Bool) {
        for subview in view.subviews {
            if subview != datePicker {
                subview.isUserInteractionEnabled = enabled
            }
            setInteractionEnabledForAllSubviews(in: subview, enabled: enabled)
        }
    }

    @objc func overlayViewTapped() {
        datePicker.isHidden = true
        overlayView.isHidden = true
    }
    
    @objc func overlayViewTapped2() {
        accountPicker.isHidden = true
        overlayView.isHidden = true
    }
    
    func updateAccountBalance(accountName: String, transaction: Transaction) {
        let realm = try! Realm()
        if let account = realm.objects(Account.self).filter("name == %@", accountName).first {
            try! realm.write {
                switch transaction.transactionType {
                case "income":
                    account.balance += transaction.amount
                case "expense":
                    account.balance -= transaction.amount
//                case "transfer":
//                    // 如果是转账，需要处理转入和转出两个账户的 balance
//                    // 假设在 Transaction 对象中有一个名为 `transferToAccountName` 的属性存储了转入账户的名称
//                    if let transferToAccount = realm.objects(Account.self).filter("name == %@", transaction.transferToAccountName).first {
//                        account.balance -= transaction.amount
//                        transferToAccount.balance += transaction.amount
//                    }
                default:
                    break
                }
            }
        }
    }

    func randomGradientColor() -> UIColor {
        let red = CGFloat(arc4random_uniform(128)) / 255.0 + 0.5
        let green = CGFloat(arc4random_uniform(128)) / 255.0 + 0.5
        let blue = CGFloat(arc4random_uniform(128)) / 255.0 + 0.5
        let alpha = CGFloat(0.6)
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}

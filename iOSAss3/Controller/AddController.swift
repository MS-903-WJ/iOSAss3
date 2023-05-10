//
//  ViewController.swift
//  iOSAss3
//
//  Created by John Wang on 2/5/2023.
//

import Foundation
import UIKit

class AddController: UIViewController {
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var transferView: UIView!
    @IBOutlet var incomeView: UIView!
    @IBOutlet var expenseView: UIView!
    
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
    
    var selectedButton: UIButton?
    
    var selectedButtonInfo: String?
    
    let moneyLabelState: String = "0.00"
    
    var equalButtonState: Bool = false
    var operaCount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        educationButton.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)
        medicalButton.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)
        transportationButton.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)
        houdingButton.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)
        clothingButton.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)
        foodButton.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)
        
        foodButton.backgroundColor = UIColor(red: 0.6, green: 0.8, blue: 1.0, alpha: 0.7)
        selectedButton = foodButton
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
        moneyLabel.text = moneyLabelState
    }
    
    @objc func buttonClicked(_ sender: UIButton) {
        // 取消上一个按钮的背景颜色
        selectedButton?.backgroundColor = nil
        
        // 设置新的按钮的背景颜色
        sender.backgroundColor = UIColor(red: 0.6, green: 0.8, blue: 1.0, alpha: 0.7)
        
        // 保存当前选中的按钮和按钮信息
        selectedButton = sender
        selectedButtonInfo = sender.titleLabel?.text
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        expenseView.isHidden = true
        incomeView.isHidden = true
        transferView.isHidden = true
        switch sender.selectedSegmentIndex {
        case 0:
            expenseView.isHidden = false
        case 1:
            incomeView.isHidden = false
        case 2:
            transferView.isHidden = false
        default:
            break
        }
    }
    
    @objc func numberButtonClicked(_ sender: UIButton) {
        let value = sender.titleLabel?.text ?? ""
        updateMoneyLabel(with: value)
    }

    @objc func operationButtonClicked(_ sender: UIButton) {
        let value = sender.titleLabel?.text ?? ""
        updateMoneyLabel(with: value)
    }

    @objc func deleteButtonClicked(_ sender: UIButton) {}

    @objc func pointButtonClicked(_ sender: UIButton) {
        let value = sender.titleLabel?.text ?? ""
        updateMoneyLabel(with: value)
    }
    
    func updateMoneyLabel(with value: String) {
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
                        // 检查是否已存在有效的小数点
                        if !moneyLabel.text!.contains(".") {
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
        guard let firstNumber = Double(components[0]),
              let secondNumber = Double(components[2])
        else {
            print("Invalid numbers in input string")
            return nil
        }
        let operation = components[1]

        // 根据操作符执行相应的操作
        let result: Double
        if operation == "+" {
            result = firstNumber - secondNumber
        } else {
            result = firstNumber + secondNumber
        }

        return String(result)
    }
}

//
//  ViewController.swift
//  iOSAss3
//
//  Created by John Wang on 3/5/2023.
//

import RealmSwift
import UIKit

class Account: Object {
    @Persisted var name: String
    @Persisted var type: String
    @Persisted var balance: Double
}

class Transaction: Object {
    @Persisted var date: Date
    @Persisted var transactionType: String
    @Persisted var expenseSource: String?
    @Persisted var incomeSource: String?
    @Persisted var amount: Double
    @Persisted var expenseCategory: String?
    @Persisted var note: String?
}

class HomeController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var addButton: UIButton!
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var incomeCard: UIView!
    @IBOutlet var expenditureCard: UIView!
    
    @IBOutlet var incomeNumber: UILabel!
    @IBOutlet var expenseNumber: UILabel!
    
    var transactions: Results<Transaction>!
    var groupedTransactions: [String: [Transaction]] = [:]
    var sortedTransactionKeys: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        expenditureCard.layer.cornerRadius = 10
        incomeCard.layer.cornerRadius = 10
        
        // Set the tableView's delegate and dataSource
        tableView.delegate = self
        tableView.dataSource = self
        
        addButton.layer.cornerRadius = addButton.frame.size.width / 2
        addButton.clipsToBounds = true
        
        // Realm database check
        do {
            let realm = try Realm()
            let accounts = realm.objects(Account.self)
            
            if accounts.isEmpty {
                // 如果没有任何账户，创建一个默认账户
                let defaultAccount = Account()
                defaultAccount.name = "default"
                defaultAccount.type = "deposit"
                defaultAccount.balance = 0
                
                try realm.write {
                    realm.add(defaultAccount)
                }
            }
            transactions = realm.objects(Transaction.self).sorted(byKeyPath: "date", ascending: false)
            
        } catch {
            print("Error accessing realm or saving account, \(error)")
        }
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        // Set the tableView's delegate and dataSource
        tableView.delegate = self
        tableView.dataSource = self
        print("TableView frame: \(tableView.frame)")
        
        groupTransactionsByDate()
        view.bringSubviewToFront(addButton)
        tableView.showsVerticalScrollIndicator = false
        
        var totalExpense = 0.0
        var totalIncome = 0.0
        for transaction in transactions {
            if transaction.transactionType == "expense" {
                totalExpense += transaction.amount
            } else {
                totalIncome += transaction.amount
            }
        }
        expenseNumber.text = String(format: "%.2f", totalExpense)
        incomeNumber.text = String(format: "%.2f", totalIncome)
        
        // Add gradient background to incomeCard and expenditureCard
        let incomeGradient = randomBlueGradient()
        incomeGradient.frame = incomeCard.bounds
        incomeGradient.cornerRadius = incomeCard.layer.cornerRadius
        incomeGradient.masksToBounds = true
        incomeCard.layer.insertSublayer(incomeGradient, at: 0)
            
        let expenditureGradient = randomRedGradient()
        expenditureGradient.frame = expenditureCard.bounds
        expenditureGradient.cornerRadius = expenditureCard.layer.cornerRadius
        expenditureGradient.masksToBounds = true
        expenditureCard.layer.insertSublayer(expenditureGradient, at: 0)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Make the button circular
        addButton.layer.cornerRadius = addButton.frame.size.width / 2
        
        let addButtonGradient = randomBlueGradient()
        addButtonGradient.frame = addButton.bounds
        addButtonGradient.cornerRadius = addButton.layer.cornerRadius
        addButtonGradient.masksToBounds = true
        addButton.layer.insertSublayer(addButtonGradient, at: 0)
    }
    
    // TableView DataSource Methods
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell")
        
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "TransactionCell")
        }
        
        let dateKey = sortedTransactionKeys[indexPath.section]
        if let transaction = groupedTransactions[dateKey]?[indexPath.row] {
            if transaction.transactionType == "expense" {
                cell!.textLabel?.text = "- \(transaction.amount)"
                cell!.textLabel?.font = UIFont.boldSystemFont(ofSize: 25) // 设置字体大小
                cell!.textLabel?.textColor = UIColor.red // 设置字体颜色
                let forString = NSAttributedString(string: "for ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13)])
                let categoryString = NSAttributedString(string: "\(transaction.expenseCategory ?? "Food") ", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15)])
                let fromString = NSAttributedString(string: "from ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13)])
                let sourceString = NSAttributedString(string: "\(transaction.expenseSource ?? "unknown source")", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15)])
                        
                let detailAttributedString = NSMutableAttributedString()
                detailAttributedString.append(forString)
                detailAttributedString.append(categoryString)
                detailAttributedString.append(fromString)
                detailAttributedString.append(sourceString)
                        
                cell!.detailTextLabel?.attributedText = detailAttributedString
            } else {
                cell!.textLabel?.text = "+ \(transaction.amount)"
                cell!.textLabel?.font = UIFont.boldSystemFont(ofSize: 25) // 设置字体大小
                let customGreenColor = UIColor(red: 0.01, green: 0.78, blue: 0.53, alpha: 1)
                cell!.textLabel?.textColor = customGreenColor
                let categoryString = NSAttributedString(string: "\(transaction.expenseCategory ?? "Food") ", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15)])
                let toString = NSAttributedString(string: "to ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13)])
                let sourceString = NSAttributedString(string: "\(transaction.incomeSource ?? "unknown source")", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15)])
                        
                let detailAttributedString = NSMutableAttributedString()
                detailAttributedString.append(categoryString)
                detailAttributedString.append(toString)
                detailAttributedString.append(sourceString)
                        
                cell!.detailTextLabel?.attributedText = detailAttributedString
            }
            
            print("Creating cell for row \(indexPath.row)")
        }
        
        return cell!
    }

    override func viewWillAppear(_ animated: Bool) {
        print("this is viewWillAppear")
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView), name: NSNotification.Name(rawValue: "reloadTableView"), object: nil)
    }
    
    @objc func reloadTableView() {
        print("this is reload function")
        
        // Refresh the transactions data
        let realm = try! Realm()
        transactions = realm.objects(Transaction.self).sorted(byKeyPath: "date", ascending: false)
        
        // Clear the existing groupedTransactions and sortedTransactionKeys
        groupedTransactions.removeAll()
        sortedTransactionKeys.removeAll()
        
        // Regroup the transactions by date
        groupTransactionsByDate()
        
        // Reload the tableView data
        tableView.reloadData()
    }
    
    func groupTransactionsByDate() {
        // Loop through all transactions
        for transaction in transactions {
            // Get the date of the transaction without the time component
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateWithoutTime = dateFormatter.string(from: transaction.date)
            
            // Check if the date is already in the groupedTransactions dictionary
            if groupedTransactions[dateWithoutTime] == nil {
                // If not, create a new array with the current transaction and add it to the dictionary
                groupedTransactions[dateWithoutTime] = [transaction]
            } else {
                // If yes, append the current transaction to the existing array for that date
                groupedTransactions[dateWithoutTime]?.append(transaction)
            }
        }
        
        // Sort the transaction keys (dates) in descending order
        sortedTransactionKeys = Array(groupedTransactions.keys).sorted(by: { $0 > $1 })
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return sortedTransactionKeys.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dateKey = sortedTransactionKeys[section]
        return groupedTransactions[dateKey]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sortedTransactionKeys[section]
    }
    
    func randomRedGradient() -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        let startColor = UIColor(red: CGFloat.random(in: 0.5...1), green: CGFloat.random(in: 0...0.5), blue: CGFloat.random(in: 0...0.5), alpha: 1)
        let endColor = UIColor(red: CGFloat.random(in: 0.5...1), green: CGFloat.random(in: 0...0.5), blue: CGFloat.random(in: 0...0.5), alpha: 1)
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        return gradientLayer
    }

    func randomBlueGradient() -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        let startColor = UIColor(red: CGFloat.random(in: 0...0.5), green: CGFloat.random(in: 0...0.5), blue: CGFloat.random(in: 0.5...1), alpha: 1)
        let endColor = UIColor(red: CGFloat.random(in: 0...0.5), green: CGFloat.random(in: 0...0.5), blue: CGFloat.random(in: 0.5...1), alpha: 1)
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        return gradientLayer
    }
}

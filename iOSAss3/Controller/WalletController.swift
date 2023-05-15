//
//  WalletController.swift
//  iOSAss3
//
//  Created by John Wang on 11/5/2023.
//

import RealmSwift
import UIKit

class WalletController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var addButton: UIButton!
    @IBOutlet var tableView: UITableView!
    var accounts: Results<Account>?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none

        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 10))
        footerView.backgroundColor = .clear
        tableView.tableFooterView = footerView
        tableView.showsVerticalScrollIndicator = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        do {
            let realm = try Realm()
            accounts = realm.objects(Account.self)
            tableView.reloadData()
        } catch {
            print("Error accessing realm, \(error)")
        }
    }

    @IBAction func addButtonClicked(_ sender: UIButton) {
        let alert = UIAlertController(title: "Add Account", message: "Enter account details", preferredStyle: .alert)

        alert.addTextField { textField in
            textField.placeholder = "Name"
        }
        alert.addTextField { textField in
            textField.placeholder = "Type"
        }
        alert.addTextField { textField in
            textField.placeholder = "Balance"
            textField.keyboardType = .decimalPad // Use decimal keyboard
        }

        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let name = alert.textFields?[0].text,
                  let type = alert.textFields?[1].text,
                  let balanceText = alert.textFields?[2].text,
                  let balance = Double(balanceText)
            else {
                return
            }

            let newAccount = Account()
            newAccount.name = name
            newAccount.type = type
            newAccount.balance = balance

            do {
                let realm = try Realm()
                try realm.write {
                    realm.add(newAccount)
                }
                self.accounts = realm.objects(Account.self)
                self.tableView.reloadData()
            } catch {
                print("Error saving account, \(error)")
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alert.addAction(saveAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AccountCell", for: indexPath) as? AccountTableViewCell else {
            fatalError("The dequeued cell is not an instance of AccountTableViewCell.")
        }

        if let account = accounts?[indexPath.row] {
            cell.configure(account: account)
        }

        cell.backgroundColor = .clear

        let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: cell.bounds.width, height: cell.bounds.height - 10))
        backgroundView.layer.cornerRadius = 10
        backgroundView.layer.masksToBounds = true

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = backgroundView.bounds
        gradientLayer.setRandomColors()
        gradientLayer.setRandomDirection()

        backgroundView.layer.insertSublayer(gradientLayer, at: 0)

        cell.contentView.addSubview(backgroundView)
        cell.contentView.sendSubviewToBack(backgroundView)

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 136
    }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(
            red: CGFloat(arc4random_uniform(256)) / 255.0,
            green: CGFloat(arc4random_uniform(256)) / 255.0,
            blue: CGFloat(arc4random_uniform(256)) / 255.0,
            alpha: 1.0
        )
    }
}

extension CAGradientLayer {
    func setRandomColors() {
        colors = [UIColor.random().cgColor, UIColor.random().cgColor]
    }

    func setRandomDirection() {
        let x = CGFloat(arc4random_uniform(3)) - 1.0
        let y = CGFloat(arc4random_uniform(3)) - 1.0
        startPoint = CGPoint(x: x, y: y)
        endPoint = CGPoint(x: 1.0 - x, y: 1.0 - y)
    }
}

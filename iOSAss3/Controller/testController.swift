//
//  testController.swift
//  iOSAss3
//
//  Created by John Wang on 12/5/2023.
//

import UIKit

class TestController: UIViewController {
    @IBOutlet var collectionView: UICollectionViewCell!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
        collectionView.register(TransactionCell.self, forCellWithReuseIdentifier: "TransactionCell")
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let dateKey = Array(groupedTransactions.keys)[section]
        return groupedTransactions[dateKey]?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TransactionCell", for: indexPath) as! TransactionCell

        let dateKey = Array(groupedTransactions.keys)[indexPath.section]
        if let transaction = groupedTransactions[dateKey]?[indexPath.row] {
            cell.textLabel.text = "\(transaction.amount)"
            cell.textLabel.font = UIFont.systemFont(ofSize: 18)
            cell.textLabel.textColor = UIColor.red

            let fromString = NSAttributedString(string: "from ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)])
            let sourceString = NSAttributedString(string: "\(transaction.expenseSource ?? "unknown source")", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)])

            let detailAttributedString = NSMutableAttributedString()
            detailAttributedString.append(fromString)
            detailAttributedString.append(sourceString)

            cell.detailTextLabel.attributedText = detailAttributedString
        }

        return cell
    }
}

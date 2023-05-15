//
//  CardTableViewCell.swift
//  iOSAss3
//
//  Created by John Wang on 12/5/2023.
//

import UIKit

class AccountTableViewCell: UITableViewCell {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var balanceLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupCardStyle()
    }

    func setupCardStyle() {
        self.contentView.layer.cornerRadius = 10
        self.contentView.layer.borderWidth = 0
        self.contentView.layer.borderColor = UIColor.lightGray.cgColor
        self.contentView.layer.masksToBounds = true

        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 4
        self.layer.shadowOpacity = 0.1
        self.layer.masksToBounds = false
    }

    func configure(account: Account) {
        self.nameLabel.text = account.name
        self.typeLabel.text = account.type
        self.balanceLabel.text = "\(account.balance)"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor(white: 0.9, alpha: 1)
        selectedBackgroundView.layer.cornerRadius = 10
        selectedBackgroundView.clipsToBounds = true

        self.selectedBackgroundView = selectedBackgroundView
    }
}

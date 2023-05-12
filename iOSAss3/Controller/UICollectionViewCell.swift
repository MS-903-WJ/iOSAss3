//
//  UICollectionViewCell.swift
//  iOSAss3
//
//  Created by John Wang on 12/5/2023.
//

import UIKit

class TransactionCell: UICollectionViewCell {
    let textLabel = UILabel()
    let detailTextLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(textLabel)
        contentView.addSubview(detailTextLabel)
        
        // You can adjust the frame or constraints of the labels here.
        // In this example, I'll just set the frame directly for simplicity.
        textLabel.frame = CGRect(x: 0, y: 0, width: contentView.bounds.width, height: contentView.bounds.height / 2)
        detailTextLabel.frame = CGRect(x: 0, y: contentView.bounds.height / 2, width: contentView.bounds.width, height: contentView.bounds.height / 2)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

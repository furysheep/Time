//
//  CardDetailsItemCell.swift
//  Time
//
//  Created by Mistake on 3/26/20.
//

import UIKit

class CardDetailsItemCell: UITableViewCell {    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var cellImageView: UIImageView!
    
    func fillDetails(_ title: String, _ subTitle: String, _ image: UIImage?) {
        titleLabel.text = title
        subtitleLabel.text = subTitle
        cellImageView.image = image
    }
}

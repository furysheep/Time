//
//  CardCell.swift
//  Time
//
//  Created by Mistake on 3/26/20.
//

import UIKit

class CardCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var leftTimeContainerView: UIView!
    @IBOutlet weak var leftTimeLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        
        // set round border to left time
        leftTimeContainerView.layer.cornerRadius = 12
        leftTimeContainerView.layer.borderColor = UIColor.white.cgColor
        leftTimeContainerView.layer.borderWidth = 1.0 / UIScreen.main.scale
    }
}

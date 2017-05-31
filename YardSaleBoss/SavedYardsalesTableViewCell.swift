//
//  SavedYardsalesTableViewCell.swift
//  YardSaleBoss
//
//  Created by Jeremiah Hawks on 3/16/17.
//  Copyright © 2017 Jeremiah Hawks. All rights reserved.
//

import UIKit

class SavedYardsalesTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet weak var yardsaleImageView: UIImageView!
    
    @IBOutlet weak var yardsaleCityStateLabel: UILabel!
    
    @IBOutlet weak var yardsaleTitleLabel: UILabel!
    
    @IBOutlet weak var cloudStarImageView: UIImageView!
    
    
    // MARK: - Properties
    
    var yardsale: Yardsale? {
        didSet {
            updateViews()
        }
    }
    
    
    // MARK: - Update Views
    
    func updateViews() {
        guard let yardsale = yardsale else { return }
        guard let image = yardsale.image else { return }
        self.yardsaleImageView.layer.cornerRadius = 10
        self.yardsaleImageView.clipsToBounds = true
        yardsaleTitleLabel.text = yardsale.title
        yardsaleCityStateLabel.text = yardsale.cityStateString
        yardsaleImageView.image = image
        if yardsale.streetAddress != nil {
            cloudStarImageView.isHidden = false
        } else {
            cloudStarImageView.isHidden = true
        }
    }
}

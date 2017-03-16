//
//  SavedYardsalesTableViewCell.swift
//  YardSaleBoss
//
//  Created by Jeremiah Hawks on 3/16/17.
//  Copyright © 2017 Jeremiah Hawks. All rights reserved.
//

import UIKit

class SavedYardsalesTableViewCell: UITableViewCell {
    @IBOutlet weak var yardsaleImageView: UIImageView!
    @IBOutlet weak var yardsaleCityStateLabel: UILabel!
    @IBOutlet weak var yardsaleTitleLabel: UILabel!
    
    static var yardsales: [Yardsale] = []
    
    var yardsale: Yardsale? {
        didSet {
            updateViews()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateViews() {
        guard let yardsale = yardsale else { return }
        guard let image = yardsale.image else { return }
        yardsaleTitleLabel.text = yardsale.title
        yardsaleCityStateLabel.text = yardsale.cityStateString
        yardsaleImageView.image = image
    }

}

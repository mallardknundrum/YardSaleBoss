//
//  SearchResultsTableViewCell.swift
//  YardSaleBoss
//
//  Created by Jeremiah Hawks on 3/15/17.
//  Copyright © 2017 Jeremiah Hawks. All rights reserved.
//

import UIKit

class SearchResultsTableViewCell: UITableViewCell {
    @IBOutlet weak var yardsaleImageView: UIImageView!
    @IBOutlet weak var yardsaleCityStateTextLabel: UILabel!
    @IBOutlet weak var yardsaleDescriptionTextView: UITextView!
    @IBOutlet weak var yardsaleTitleLabel: UILabel!
    @IBOutlet weak var selectedButton: UIButton!
    
    var yardsale: Yardsale? {
        didSet {
            updateViews()
        }
    }

    @IBAction func selectButtonTapped(_ sender: Any) {
        guard let yardsale = yardsale else { return }
        if SavedYardsalesTableViewCell.yardsales.contains(yardsale) {
            guard let index = SavedYardsalesTableViewCell.yardsales.index(of: yardsale) else { return }
            SavedYardsalesTableViewCell.yardsales.remove(at: index)
            selectedButton.setTitle("", for: .normal)
        } else {
            SavedYardsalesTableViewCell.yardsales.append(yardsale)
            selectedButton.setTitle("Selected", for: .normal)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateViews() {
        guard let description = yardsale?.yardsaleDescription, let cityState = yardsale?.cityStateString, let title = yardsale?.title else { return }
        if let image = yardsale?.image {
            yardsaleImageView.image = image
        }
        yardsaleTitleLabel.text = title
        yardsaleCityStateTextLabel.text = cityState
        yardsaleDescriptionTextView.text = description
    }

}

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
        if YardsaleController.shared.savedYardsales.contains(yardsale) {
            guard let index = YardsaleController.shared.savedYardsales.index(of: yardsale) else { return }
            YardsaleController.shared.savedYardsales.remove(at: index)
            updateViews()
        } else if !YardsaleController.shared.savedYardsales.contains(yardsale) {
            YardsaleController.shared.savedYardsales.append(yardsale)
            updateViews()
        }
    }
    
    func updateViews() {
        selectedButton.isEnabled = true
        guard let yardsale = yardsale else { return }
        let description = yardsale.yardsaleDescription
        let cityState = yardsale.cityStateString
        let title = yardsale.title
        if let image = yardsale.image {
            yardsaleImageView.image = image
        }
        yardsaleTitleLabel.text = title
        yardsaleCityStateTextLabel.text = cityState
        yardsaleDescriptionTextView.text = description
        if YardsaleController.shared.savedYardsales.contains(yardsale) {
            selectedButton.setTitle("Selected", for: .normal)
            selectedButton.backgroundColor = UIColor.gray
            selectedButton.titleLabel?.textColor = UIColor.gray
        } else if !YardsaleController.shared.savedYardsales.contains(yardsale) {
            selectedButton.setTitle("", for: .normal)
            selectedButton.backgroundColor = UIColor.clear
            selectedButton.titleLabel?.textColor = UIColor.gray
        }
    }
}

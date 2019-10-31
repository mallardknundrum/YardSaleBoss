//
//  SearchResultsTableViewCell.swift
//  YardSaleBoss
//
//  Created by Jeremiah Hawks on 3/15/17.
//  Copyright © 2017 Jeremiah Hawks. All rights reserved.
//

import UIKit

class SearchResultsTableViewCell: UITableViewCell {

  // MARK: - Outlets
  @IBOutlet weak var yardsaleImageView: UIImageView!
  @IBOutlet weak var yardsaleCityStateTextLabel: UILabel!
  @IBOutlet weak var yardsaleDescriptionTextView: UITextView!
  @IBOutlet weak var yardsaleTitleLabel: UILabel!
  @IBOutlet weak var selectedButton: UIButton!
  @IBOutlet weak var cloudStarImageView: UIImageView!

  // MARK: - Properties
  var yardsale: Yardsale? {
    didSet {
      updateViews()
    }
  }

  // MARK: - IBActions
  @IBAction func selectButtonTapped(_ sender: Any) {
    guard let yardsale = yardsale else { return }
    if YardsaleController.shared.savedYardsales.contains(yardsale) {
      guard let index = YardsaleController.shared.savedYardsales.firstIndex(of: yardsale) else { return }
      YardsaleController.shared.savedYardsales.remove(at: index)
      if User.savedYardsaleIDs.contains(yardsale.kslID) {
        guard let index = User.savedYardsaleIDs.firstIndex(of: yardsale.kslID) else { return }
        User.savedYardsaleIDs.remove(at: index)
        UserDefaults.standard.set(User.savedYardsaleIDs, forKey: "savedYardsaleIDs")
        print(User.savedYardsaleIDs)
        UserDefaults.standard.synchronize()
      }
      updateViews()
    } else if !YardsaleController.shared.savedYardsales.contains(yardsale) {
      YardsaleController.shared.savedYardsales.append(yardsale)
      User.savedYardsaleIDs.append(yardsale.kslID)
      UserDefaults.standard.set(User.savedYardsaleIDs, forKey: "savedYardsaleIDs")
      print(User.savedYardsaleIDs.description)
      UserDefaults.standard.synchronize()
      updateViews()
    }
  }

  // MARK: - Update Views
  func updateViews() {
    selectedButton.isEnabled = true
    guard let yardsale = yardsale else { return }
    let description = yardsale.yardsaleDescription
    let cityState = yardsale.cityStateString
    let title = yardsale.title
    if let image = yardsale.image {
      yardsaleImageView.image = image
      yardsaleImageView.layer.cornerRadius = 10
      yardsaleImageView.clipsToBounds = true
    }
    yardsaleTitleLabel.text = title
    yardsaleCityStateTextLabel.text = cityState
    yardsaleDescriptionTextView.text = description
    if YardsaleController.shared.savedYardsales.contains(yardsale) {
      selectedButton.setBackgroundImage(#imageLiteral(resourceName: "Selected"), for: .normal)
    } else if !YardsaleController.shared.savedYardsales.contains(yardsale) {
      selectedButton.setBackgroundImage(nil, for: .normal)
      selectedButton.setTitle("", for: .normal)
      selectedButton.backgroundColor = UIColor.clear
      selectedButton.titleLabel?.textColor = UIColor.gray
    }
    if yardsale.streetAddress != nil {
      cloudStarImageView.isHidden = false
    } else {
      cloudStarImageView.isHidden = true
    }
  }
}

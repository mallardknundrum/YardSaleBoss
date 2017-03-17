//
//  DetailViewController.swift
//  YardSaleBoss
//
//  Created by Jeremiah Hawks on 3/17/17.
//  Copyright © 2017 Jeremiah Hawks. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var yardsaleImageView: UIImageView!
    @IBOutlet weak var yardsaleTitleLabel: UILabel!
    @IBOutlet weak var yardsaleCityStateLabel: UILabel!
    @IBOutlet weak var yardsaleStreetAddressTextField: UITextField!
    @IBOutlet weak var yardsaleDescriptionTextView: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var yardsale: Yardsale? {
        didSet {
            if isViewLoaded {
                updateViews()
            }
        }
    }
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let yardsale = yardsale else { return }
        yardsale.streetAddress = yardsaleStreetAddressTextField.text
        let yardsales = YardsaleController.shared.yardsales
        let savedYardsales = YardsaleController.shared.savedYardsales
        if yardsales.contains(yardsale) {
            guard let index = yardsales.index(of: yardsale) else { return }
            YardsaleController.shared.yardsales[index].streetAddress = yardsaleStreetAddressTextField.text
        }
        if savedYardsales.contains(yardsale) {
            guard let index = yardsales.index(of: yardsale) else { return }
            YardsaleController.shared.savedYardsales[index].streetAddress = yardsaleStreetAddressTextField.text
            
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        scrollView.contentInset.bottom = 290
        scrollView.contentInset.top = 0
    }
    
    
    
    func updateViews() {
        guard let yardsale = yardsale else { return }
        if !isViewLoaded {
            loadView()
        }
        if yardsale.streetAddress != nil {
            yardsaleStreetAddressTextField.text = yardsale.streetAddress
        }
        yardsaleImageView.image = yardsale.image
        yardsaleTitleLabel.text = yardsale.title
        yardsaleCityStateLabel.text = yardsale.city
        yardsaleDescriptionTextView.text = yardsale.yardsaleDescription
    }
}

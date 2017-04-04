//
//  DetailViewController.swift
//  YardSaleBoss
//
//  Created by Jeremiah Hawks on 3/17/17.
//  Copyright © 2017 Jeremiah Hawks. All rights reserved.
//

import UIKit
import CloudKit
import os.log



class DetailViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var yardsaleImageView: UIImageView!
    @IBOutlet weak var yardsaleTitleLabel: UILabel!
    @IBOutlet weak var yardsaleStreetAddressTextField: UITextField!
    @IBOutlet weak var yardsaleDescriptionTextView: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var yardsaleCityTextField: UITextField!
    @IBOutlet weak var yardsaleStateTextField: UITextField!
    @IBOutlet var keyboardHeightLayoutConstraint: NSLayoutConstraint?
    
    
    var yardsale: Yardsale? {
        didSet {
            if isViewLoaded {
                updateViews()
            }
        }
    }
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let yardsale = yardsale else { return }
        yardsale.streetAddress = yardsaleStreetAddressTextField.text?.replacingOccurrences(of: "#", with: "Apt")
        let yardsales = YardsaleController.shared.yardsales
        let savedYardsales = YardsaleController.shared.savedYardsales
        if yardsales.contains(yardsale) {
            guard let index = yardsales.index(of: yardsale) else { return }
            YardsaleController.shared.yardsales[index].streetAddress = yardsaleStreetAddressTextField.text
            if let city = yardsaleCityTextField.text, let state = yardsaleStateTextField.text, city != "", state != "" {
                YardsaleController.shared.yardsales[index].cityStateString = city + ", " + state
            }
        }
        if savedYardsales.contains(yardsale) {
            guard let index = savedYardsales.index(of: yardsale) else { return }
            YardsaleController.shared.savedYardsales[index].streetAddress = yardsaleStreetAddressTextField.text
            if let city = yardsaleCityTextField.text, let state = yardsaleStateTextField.text, city != "", state != "" {
                YardsaleController.shared.savedYardsales[index].cityStateString = city + ", " + state
            }
        }
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
        let ckRecord = CKRecord(yardsale)
        CloudKitManager.shared.saveRecord(ckRecord) { (record, error) in
            if let error = error {
                print("problem saving CKRecord \n\(error.localizedDescription)")
            }
            if let record = record {
                print("Succesfully saved record to cloud")
            }
        }
        CloudKitManager.shared.modifyRecords([ckRecord], perRecordCompletion: { (record, error) in
            if let error = error {
                print("failed to update CKR")
            }
            if let record = record {
                os_log("success updating record")
            }
        }) { (records, error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        self.navigationController?.navigationBar.backItem?.hidesBackButton = true
        self.navigationController?.navigationBar.tintColor = UIColor(colorLiteralRed: 232.0 / 255.0, green: 232.0 / 255.0, blue: 232.0 / 255.0, alpha: 1.0)
        self.navigationController?.navigationBar.backgroundColor = UIColor(colorLiteralRed: 232.0 / 255.0, green: 232.0 / 255.0, blue: 232.0 / 255.0, alpha: 1.0)
        self.navigationController?.navigationBar.barTintColor = UIColor(colorLiteralRed: 232.0 / 255.0, green: 232.0 / 255.0, blue: 232.0 / 255.0, alpha: 1.0)
//        self.navigationController?.navigationBar.isTranslucent = false

        self.navigationItem.hidesBackButton = true
    }
    
    deinit {
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
        yardsaleImageView.layer.cornerRadius = 10
        yardsaleImageView.clipsToBounds = true
        yardsaleTitleLabel.text = yardsale.title
        yardsaleCityTextField.text = yardsale.city
        yardsaleStateTextField.text = yardsale.state
        yardsaleDescriptionTextView.text = yardsale.yardsaleDescription
        yardsaleDescriptionTextView.layer.cornerRadius = 10
    }
}

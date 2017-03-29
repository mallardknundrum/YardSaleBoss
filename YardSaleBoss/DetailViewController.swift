//
//  DetailViewController.swift
//  YardSaleBoss
//
//  Created by Jeremiah Hawks on 3/17/17.
//  Copyright © 2017 Jeremiah Hawks. All rights reserved.
//

import UIKit
import CloudKit

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
                print ("success updating record")
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
//        scrollView.contentInset.bottom = 290
//        scrollView.contentInset.top = 0
//        NotificationCenter.default.addObserver(self,
//                                                         selector: #selector(self.keyboardNotification(notification:)),
//                                                         name: NSNotification.Name.UIKeyboardWillChangeFrame,
//                                                         object: nil)
    }
    
    deinit {
//        NotificationCenter.default.removeObserver(self)
    }
    
//    func keyboardNotification(notification: NSNotification) {
//        if let userInfo = notification.userInfo {
//            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
//            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
//            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
//            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
//            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
//            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
//                self.keyboardHeightLayoutConstraint?.constant = 0.0
//            } else {
//                self.keyboardHeightLayoutConstraint?.constant = endFrame?.size.height ?? 0.0
//            }
//            UIView.animate(withDuration: duration,
//                           delay: TimeInterval(0),
//                           options: animationCurve,
//                           animations: { self.view.layoutIfNeeded() },
//                           completion: nil)
//        }
//    }
    
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
        yardsaleCityTextField.text = yardsale.city
        yardsaleStateTextField.text = yardsale.state
        yardsaleDescriptionTextView.text = yardsale.yardsaleDescription
    }
}

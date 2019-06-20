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

class DetailViewController: UIViewController, UITextFieldDelegate {
  // MARK: - Outlets
  @IBOutlet weak var yardsaleImageView: UIImageView!
  @IBOutlet weak var yardsaleTitleLabel: UILabel!
  @IBOutlet weak var yardsaleStreetAddressTextField: UITextField!
  @IBOutlet weak var yardsaleDescriptionTextView: UITextView!
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var yardsaleCityTextField: UITextField!
  @IBOutlet weak var yardsaleStateTextField: UITextField!
  @IBOutlet var keyboardHeightLayoutConstraint: NSLayoutConstraint?

  // MARK: - Properties
  var showTutorial = false
  var yardsale: Yardsale? {
    didSet {
      if isViewLoaded {
        updateViews()
      }
    }
  }

  // MARK: - IBActions
  @IBAction func saveButtonTapped(_ sender: Any) {
    guard let yardsale = yardsale else { return }
    yardsale.streetAddress = yardsaleStreetAddressTextField.text?.replacingOccurrences(of: "#", with: "Apt")
    let yardsales = YardsaleController.shared.yardsales
    let savedYardsales = YardsaleController.shared.savedYardsales
    if yardsales.contains(yardsale) {
      guard let index = yardsales.firstIndex(of: yardsale) else { return }
      YardsaleController.shared.yardsales[index].streetAddress = yardsaleStreetAddressTextField.text
      if let city = yardsaleCityTextField.text, let state = yardsaleStateTextField.text, city != "", state != "" {
        YardsaleController.shared.yardsales[index].cityStateString = city + ", " + state
      }
    }
    if savedYardsales.contains(yardsale) {
      guard let index = savedYardsales.firstIndex(of: yardsale) else { return }
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
      if let _ = record {
        print("Succesfully saved record to cloud")
      }
    }
    CloudKitManager.shared.modifyRecords([ckRecord], perRecordCompletion: { (record, error) in
      if let _ = error {
        print("failed to update CKR")
      }
      if let _ = record {
        os_log("success updating record")
      }
    }) { (records, error) in
      if let error = error {
        print(error.localizedDescription)
      }
    }
  }

  // MARK: - Tableview Lifecycle Functions
  override func viewDidLoad() {
    super.viewDidLoad()
    updateViews()
    self.navigationController?.navigationBar.backgroundColor = UIColor(red: 232.0 / 255.0, green: 232.0 / 255.0, blue: 232.0 / 255.0, alpha: 1.0)
    self.navigationController?.navigationBar.barTintColor = UIColor(red: 232.0 / 255.0, green: 232.0 / 255.0, blue: 232.0 / 255.0, alpha: 1.0)
    self.navigationController?.navigationBar.tintColor = .red
    navigationItem.backBarButtonItem?.title = "Cancel"

    NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    self.yardsaleCityTextField.delegate = self
    self.yardsaleStateTextField.delegate = self
    self.yardsaleStreetAddressTextField.delegate = self
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.textFieldShouldReturn))
    view.addGestureRecognizer(tapGesture)
    if let showTutorial = UserDefaults.standard.object(forKey: "showDetailViewTutorial") as? Bool {
      self.showTutorial = showTutorial
      UserDefaults.standard.set(showTutorial, forKey: "showDetailViewTutorial")
    } else {
      self.showTutorial = true
      UserDefaults.standard.set(true, forKey: "showDetailViewTutorial")
    }
    if self.showTutorial {
      self.yardsale = Yardsale(title: "Mock Yardsale", yardsaleDescription: "This is a demonstration yardsale. Normally people would post the address of the yardsale here. Here is a sample address: \n\n Address: 301 S Temple, Salt Lake City, UT. You will need to copy the street address and paste it in the address box above. Also, check the city and state. No abbreviations are allowed for the city. For example, SLC will not work. It needs to say Salt Lake City (capitalization is not important). ", yardsaleURL: "www.someRandomYardsale.com", imageURL: "www.randomimage.com", timeOnSite: "30min", cityStateString: "Salt Lake City, UT", image: #imageLiteral(resourceName: "dummyYardsale"), kslID: "gibberish")
    }
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if self.showTutorial {
      TutorialController.shared.searchTutorial(viewController: self, title:  "This shows yardsale details!", message: "Here you can edit yardsales. You can correct the city and state if needed. You can copy and past the address from the description to the address box. The city cannot be an abbreviation. Make sure to click save (top right corner) when you're done editing. Only the first user needs to update the address, city, and state. After that, those updates are available to everyone!\n\nOnly yardsales you edit and save will be stored in your list when you close and reopen the app.", alertActionTitle: "Show me the next tab!", completion: {
        self.yardsale = nil
        UserDefaults.standard.set(false, forKey: "showDetailViewTutorial")
        self.showTutorial = false
        if let navController = self.navigationController {
          navController.popViewController(animated: true)
        }
        self.tabBarController?.selectedIndex = 2
      })
    }
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
  }

  deinit {
  }
  func backButtonTapped() {

  }

  // MARK: - Update Views
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


  // MARK: - Keyboard management

  func textFieldResignFirstResponder(gesture: UITapGestureRecognizer) {
    yardsaleStreetAddressTextField.resignFirstResponder()
    yardsaleCityTextField.resignFirstResponder()
    yardsaleStateTextField.resignFirstResponder()
  }

  @objc func keyboardWillShow(notification: NSNotification) {
    var animationDuration: TimeInterval = 0.25
    if let duration =
      notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber {
      animationDuration = duration.doubleValue
    }
    UIView.animate(withDuration: animationDuration) {
      if let kbSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
        if self.view.frame.origin.y == 0 {
          self.view.frame.origin.y -= kbSize.height
        }
      }
    }
  }

  @objc func keyboardWillHide(notification: NSNotification) {
    var animationDuration: TimeInterval = 0.25
    if let duration =
      notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber {
      animationDuration = duration.doubleValue
    }
    UIView.animate(withDuration: animationDuration) {
      if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
        if self.view.frame.origin.y != 0{
          self.view.frame.origin.y += keyboardSize.height
        }
      }
    }
  }

  func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
    self.view.endEditing(true)
    return false
  }
}

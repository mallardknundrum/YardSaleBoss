//
//  SearchResultsTableViewController.swift
//  YardSaleBoss
//
//  Created by Jeremiah Hawks on 3/13/17.
//  Copyright © 2017 Jeremiah Hawks. All rights reserved.
//

import UIKit
import CloudKit
import CoreLocation
import NotificationCenter

class SearchResultsTableViewController: UITableViewController, CLLocationManagerDelegate {
  // MARK: - Outlets
  @IBOutlet weak var zipcodeTextField: UITextField!
  @IBOutlet weak var cityTextField: UITextField!
  @IBOutlet weak var stateTextField: UITextField!
  @IBOutlet weak var searchRadiusTextField: UITextField!
  @IBOutlet weak var switchState: UISwitch!
  @IBOutlet weak var advancedSearchSwitchState: UISwitch!
  @IBOutlet weak var searchBoxView: UIView!
  @IBOutlet weak var advancedSerachBoxView: UIView!
  @IBAction func advancedSearchSwitchStateChanged(_ sender: Any) {
    advancedSearchEnabled()
  }

  // MARK: - Properties
  let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.whiteLarge)
  var showTutorial = false
  let stateDictionary = ["UTAH": "UT", "IDAHO": "ID", "WYOMING": "WY"]
  var zipcode: String? = ""
  var city: String? = ""
  var state: String? = ""

  // MARK: - Tableview lifecycle functions
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 140
    let savedYardsaleIDs = User.savedYardsaleIDs
    var savedYardsaleReference: [CKRecord.ID] = []
    for id in savedYardsaleIDs {
      savedYardsaleReference.append(CKRecord.ID(recordName: id))
    }
    let spinner = startActivityIndicatorView()
    view.bringSubviewToFront(activityIndicator)
    CloudKitManager.shared.fetchRecords(forRecordIDs: savedYardsaleReference) { (yardsales) in
      YardsaleController.shared.savedYardsales = yardsales
      DispatchQueue.main.async {
        self.stopActivityIndicatorView(activityView: spinner)
        self.tabBarController?.reloadInputViews()
      }
    }
    searchSwitchTriggered(switchState)
    LocationManager.shared.locationManager.delegate = self
    self.advancedSearchEnabled()
    if let showTutorial = UserDefaults.standard.object(forKey: "showSearchTutorial") as? Bool {
      self.showTutorial = showTutorial
      UserDefaults.standard.set(showTutorial, forKey: "showSearchTutorial")
    } else {
      self.showTutorial = true
      UserDefaults.standard.set(true, forKey: "showSearchTutorial")
    }
    self.tabBarController?.tabBar.tintColor = UIColor.blue
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tableView.reloadData()
    self.tableView.backgroundColor = UIColor(red: 232.0 / 255.0, green: 232.0 / 255.0, blue: 232.0 / 255.0, alpha: 1.0)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if self.showTutorial {
      TutorialController.shared.searchTutorial(viewController: self, title:  "Welcome to iYardsale!", message: "You are on the first tab (there are 3 tabs along the bottom). \n\nThis is where you search. You can just tap the search button and it will find yardsales within 10 miles of your current location. \n\nYardsales with a star in the top left corner already have an address filled in. \n\nYou can click on the switch in the top right corner to used more advanced search features. \n\nSimply click on the photo to add a yardsale to your saved yardsale list. \n\nIf you aren't interested in a particular yardsale, you can swipe to delete it and get it out of your way!", alertActionTitle: "Show me the next tab", completion: {
        UserDefaults.standard.set(false, forKey: "showSearchTutorial")
        self.showTutorial = false
        self.tabBarController?.selectedIndex = 1
      })
    }
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    self.view.superview!.backgroundColor = UIColor.white
    let insets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    self.view.frame = self.view.bounds.inset(by: insets)
  }

  // MARK: - Set up LocationManager
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error)-> Void in
      if error != nil {
        print("Reverse geocoder failed.")
        return
      }

      if let placemarks = placemarks {
        if placemarks.count > 0 {
          let placemark = placemarks[0]
          self.zipcode = placemark.postalCode
          self.zipcodeTextField.text = self.zipcode
          self.state = placemark.administrativeArea
          self.city = placemark.locality
          LocationManager.shared.placemark = placemark
          LocationManager.shared.locationManager.stopUpdatingLocation()
          self.tableView.reloadData()
        }else{
          print("No placemarks found.")
        }
      }
    })
  }

  func advancedSearchEnabled() {
    if self.advancedSearchSwitchState.isOn {
      UIView.animate(withDuration: 0.5, animations: {
        self.advancedSerachBoxView.isHidden = false
        self.searchBoxView.frame.size.height = 215
      })
    } else {
      UIView.animate(withDuration: 0.5, animations: {
        self.advancedSerachBoxView.isHidden = true
        self.searchBoxView.frame.size.height = CGFloat(215 - 148)
      })
    }
    self.tableView.reloadInputViews()
    self.tableView.reloadData()
  }

  // MARK: - IBAction functions
  @IBAction func searchSwitchTriggered(_ sender: UISwitch) {
    if switchState.isOn {
      cityTextField.isEnabled = false
      //            cityTextField.isHidden = true
      stateTextField.isEnabled = false
      //            stateTextField.isHidden = true
      zipcodeTextField.isEnabled = true
      //            zipcodeTextField.isHidden = false
      zipcodeTextField.text = self.zipcode
      stateTextField.text = ""
      cityTextField.text = ""
    } else if !switchState.isOn {
      cityTextField.isEnabled = true
      //            cityTextField.isHidden = false
      stateTextField.isEnabled = true
      //            stateTextField.isHidden = false
      zipcodeTextField.isEnabled = false
      //            zipcodeTextField.isHidden = true
      zipcodeTextField.text = ""
      stateTextField.text = self.state
      cityTextField.text = self.city
    }
  }

  @IBAction func searchButtonTapped(_ sender: Any) {
    var city = ""
    var state = ""
    var searchRadius = "10"
    var zipcode = ""
    if switchState.isOn {
      if let zip = zipcodeTextField.text {
        if zip.count != 5 {
          if let currentZip = self.zipcode {
            zipcode = currentZip
          }
        }
        zipcode = zip
      }
    }
    if !switchState.isOn {
      if let c = cityTextField.text {
        if c != "" {
          city = c
        }
      } else {
        if let c = self.city {
          city = c
        }
      }
      if let s = stateTextField.text {
        if s.count == 2 && s != "  " {
          state = s.uppercased()
        }
      } else {
        if let s = self.state {
          state = s
        }
      }
    }

    if let searchRadiusText = searchRadiusTextField.text {
      if searchRadiusText != "" {
        searchRadius = searchRadiusText
      }
    }
    let spinner = startActivityIndicatorView()
    YardsaleController.shared.fetchYardsales(withCity: city, state: state, zipcode: zipcode, andDistance: searchRadius) { (yardsaleArray) in
      var yardsaleIDs: [CKRecord.ID] = []
      var kslYardsales = yardsaleArray
      var cloudYardsales: [Yardsale] = []
      for yardsale in yardsaleArray {
        yardsaleIDs.append(CKRecord.ID(recordName: yardsale.kslID))
      }
      CloudKitManager.shared.fetchRecords(forRecordIDs: yardsaleIDs, completion: { (yardsales) in
        cloudYardsales = yardsales
        for (index, yardsale) in kslYardsales.enumerated() {
          if cloudYardsales.contains(yardsale) {
            if let cloudYardsaleIndex = cloudYardsales.firstIndex(of: yardsale) {
              let cloudYardsale = cloudYardsales[cloudYardsaleIndex]
              kslYardsales.remove(at: index)
              kslYardsales.insert(cloudYardsale, at: index)
            }
          }
        }
        YardsaleController.shared.yardsales = kslYardsales
        DispatchQueue.main.async {
          self.stopActivityIndicatorView(activityView: spinner)
          self.tableView.reloadData()
        }
      })
    }
    view.endEditing(true)
  }

  // MARK: - Activity Indicator
  func startActivityIndicatorView() -> UIActivityIndicatorView {
    let x = (self.view.frame.width / 2)
    let y = (self.view.frame.height / 2)

    let activityView = UIActivityIndicatorView(style: .whiteLarge)
    activityView.frame = CGRect(x: 200, y: 120, width: 200, height: 200)
    activityView.center = CGPoint(x: x, y: y)
    activityView.color = UIColor(red: 55.0 / 255.0, green: 55.0 / 255.0, blue: 55.0 / 255.0, alpha: 1.0)

    activityView.startAnimating()
    self.view.addSubview(activityView)

    return activityView
  }

  func stopActivityIndicatorView(activityView: UIActivityIndicatorView) {
    DispatchQueue.main.async {
      self.view.willRemoveSubview(activityView)
      activityView.removeFromSuperview()
    }
  }

  // MARK: - Table view data source
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "Search Results"
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let yardsales = YardsaleController.shared.yardsales
    return yardsales.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultCell", for: indexPath) as? SearchResultsTableViewCell else { return UITableViewCell() }
    cell.yardsale = YardsaleController.shared.yardsales[indexPath.row]
    cell.layer.cornerRadius = 10
    cell.layer.borderWidth = 2.0
    cell.layer.borderColor = (UIColor(red: 142.0 / 255, green: 141.0 / 255, blue: 141.0 / 255, alpha: 1)).cgColor


    return cell
  }

  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      YardsaleController.shared.yardsales.remove(at: indexPath.row)
      tableView.deleteRows(at: [indexPath], with: .fade)
      self.tableView.reloadData()
    }
  }

  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let lastKSLElement = YardsaleController.shared.yardsales.count - 1
    guard YardsaleController.shared.kslNextPageURLString != "" else { return }
    if indexPath.row == lastKSLElement {
      let origin = cell.frame.origin
      let spinner = startActivityIndicatorView()
      let screenSize = UIScreen.main.bounds
      let x = screenSize.width / 2
      let y = origin.y - cell.frame.height * 0.5
      spinner.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
      spinner.backgroundColor = UIColor(red: 191.0 / 255, green: 191.0 / 255, blue: 191.0 / 255, alpha: 1)
      spinner.center = CGPoint(x: x, y: y)
      YardsaleController.shared.kslNextPage(completion: { (yardsales) in
        var yardsaleIDs: [CKRecord.ID] = []
        var kslYardsales = yardsales
        var cloudYardsales: [Yardsale] = []
        for yardsale in kslYardsales {
          yardsaleIDs.append(CKRecord.ID(recordName: yardsale.kslID))
        }
        CloudKitManager.shared.fetchRecords(forRecordIDs: yardsaleIDs, completion: { (yardsales) in
          cloudYardsales = yardsales
          for (index, yardsale) in kslYardsales.enumerated() {
            if cloudYardsales.contains(yardsale) {
              if let cloudYardsaleIndex = cloudYardsales.firstIndex(of: yardsale) {
                let cloudYardsale = cloudYardsales[cloudYardsaleIndex]
                kslYardsales.remove(at: index)
                kslYardsales.insert(cloudYardsale, at: index)
              }
            }
          }
          YardsaleController.shared.yardsales.append(contentsOf: kslYardsales)
          DispatchQueue.main.async {
            self.stopActivityIndicatorView(activityView: spinner)
            self.tableView.reloadData()
          }
        })
      })
    }
  }
}

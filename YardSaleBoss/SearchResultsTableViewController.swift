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
    
    let stateDictionary = ["UTAH": "UT", "IDAHO": "ID", "WYOMING": "WY"]
    

    var zipcode: String? = ""
    var city: String? = ""
    var state: String? = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
        
        let savedYardsaleIDs = User.savedYardsaleIDs
        var savedYardsaleReference: [CKRecordID] = []
        for id in savedYardsaleIDs {
            savedYardsaleReference.append(CKRecordID(recordName: id))
        }
        CloudKitManager.shared.fetchRecords(forRecordIDs: savedYardsaleReference) { (yardsales) in
            YardsaleController.shared.savedYardsales = yardsales
            DispatchQueue.main.async {
                self.tabBarController?.reloadInputViews()
            }
        }
        searchSwitchTriggered(switchState)
        LocationManager.shared.locationManager.delegate = self
        
    }
    
    
    // MARK: - locationManager
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.superview!.backgroundColor = UIColor.white
        let insets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        self.view.frame = UIEdgeInsetsInsetRect(self.view.superview!.bounds, insets)
    }
    
    
    
    @IBAction func searchSwitchTriggered(_ sender: UISwitch) {
        if switchState.isOn {
            cityTextField.isEnabled = false
            cityTextField.isHidden = true
            stateTextField.isEnabled = false
            stateTextField.isHidden = true
            zipcodeTextField.isEnabled = true
            zipcodeTextField.isHidden = false
            zipcodeTextField.text = self.zipcode
            stateTextField.text = ""
            cityTextField.text = ""
        } else if !switchState.isOn {
            cityTextField.isEnabled = true
            cityTextField.isHidden = false
            stateTextField.isEnabled = true
            stateTextField.isHidden = false
            zipcodeTextField.isEnabled = false
            zipcodeTextField.isHidden = true
            zipcodeTextField.text = ""
            stateTextField.text = self.state
            cityTextField.text = self.city
        }
    }
    
    // MARK: - Search Function
    @IBAction func searchButtonTapped(_ sender: Any) {
        var city = ""
        var state = ""
        var searchRadius = "10"
        var zipcode = ""
        if switchState.isOn {
            if let zip = zipcodeTextField.text {
                if zip.characters.count != 5 {
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
                if s.characters.count == 2 && s != "  " {
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
        
        YardsaleController.shared.fetchYardsales(withCity: city, state: state, zipcode: zipcode, andDistance: searchRadius) { (yardsaleArray) in
            var yardsaleIDs: [CKRecordID] = []
            var kslYardsales = yardsaleArray
            var cloudYardsales: [Yardsale] = []
            for yardsale in yardsaleArray {
                yardsaleIDs.append(CKRecordID(recordName: yardsale.kslID))
            }
            CloudKitManager.shared.fetchRecords(forRecordIDs: yardsaleIDs, completion: { (yardsales) in
                cloudYardsales = yardsales
                for (index, yardsale) in kslYardsales.enumerated() {
                    if cloudYardsales.contains(yardsale) {
                        if let cloudYardsaleIndex = cloudYardsales.index(of: yardsale) {
                            let cloudYardsale = cloudYardsales[cloudYardsaleIndex]
                            kslYardsales.remove(at: index)
                            kslYardsales.insert(cloudYardsale, at: index)
                        }
                    }
                }
                YardsaleController.shared.yardsales = kslYardsales
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            })
        }
        view.endEditing(true)
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
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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
            YardsaleController.shared.kslNextPage(completion: { (yardsales) in
                var yardsaleIDs: [CKRecordID] = []
                var kslYardsales = yardsales
                var cloudYardsales: [Yardsale] = []
                for yardsale in kslYardsales {
                    yardsaleIDs.append(CKRecordID(recordName: yardsale.kslID))
                }
                CloudKitManager.shared.fetchRecords(forRecordIDs: yardsaleIDs, completion: { (yardsales) in
                    cloudYardsales = yardsales
                    for (index, yardsale) in kslYardsales.enumerated() {
                        if cloudYardsales.contains(yardsale) {
                            if let cloudYardsaleIndex = cloudYardsales.index(of: yardsale) {
                                let cloudYardsale = cloudYardsales[cloudYardsaleIndex]
                                kslYardsales.remove(at: index)
                                kslYardsales.insert(cloudYardsale, at: index)
                            }
                        }
                    }
                    YardsaleController.shared.yardsales.append(contentsOf: kslYardsales)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                })
            })
        }
    }
}

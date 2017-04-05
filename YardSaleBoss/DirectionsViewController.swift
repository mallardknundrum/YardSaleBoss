//
//  DirectionsViewController.swift
//  YardSaleBoss
//
//  Created by Jeremiah Hawks on 3/21/17.
//  Copyright © 2017 Jeremiah Hawks. All rights reserved.
//

import UIKit
import CoreLocation
import Contacts

class DirectionsViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate  {
    
    var address: String?
    
    @IBOutlet weak var startingAddressTextField: UITextField!
    @IBOutlet weak var endingAddressTextField: UITextField!
    @IBAction func troubleshootingButtonTapped(_ sender: Any) {
        troubleShootingAlert()
    }
    @IBAction func useCurrentButtonTapped(_ sender: Any) {
        startingAddressTextField.text = address
    }
    @IBAction func startAddClearButtonTapped(_ sender: Any) {
        startingAddressTextField.text = ""
    }
    @IBAction func endAddUseCurrentTapped(_ sender: Any) {
        endingAddressTextField.text = address
    }
    @IBAction func endAddClearButtonTapped(_ sender: Any) {
        endingAddressTextField.text = ""
    }
    
    
    @IBAction func directionsButtonTapped(_ sender: Any) {
        var startingAddress = ""
        var endingAddress = ""
        if let startAdd = startingAddressTextField.text {
            if startAdd != "" {
                startingAddress = startAdd
            } else if let address = self.address {
                startingAddress = address
            }
        } else {
            self.checkStartEndAlert()
        }
        
        if let endAdd = endingAddressTextField.text {
            if endAdd != "" {
                endingAddress = endAdd
            } else if let address = self.address {
                endingAddress = address
            }
        } else {
            self.checkStartEndAlert()
        }
        
        User.startAddress = startingAddress.replacingOccurrences(of: ",", with: " ")
        User.endAddress = endingAddress.replacingOccurrences(of: ",", with: " ")
        UserDefaults.standard.set(startingAddress.replacingOccurrences(of: ",", with: " "), forKey: "startingAddress")
        UserDefaults.standard.set(endingAddress.replacingOccurrences(of: ",", with: " "), forKey: "endingAddress")
        UserDefaults.standard.synchronize()
        
        for yardsale in YardsaleController.shared.savedYardsales {
            guard yardsale.streetAddress != nil && yardsale.streetAddress != "" else {
                self.checkAddressesAlert()
                self.tabBarController?.selectedIndex = 1
                return
            }
        }
        GoogleDirectionsController.shared.fetchGoogleMapsLink()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let start = UserDefaults.standard.string(forKey: "startingAddress") {
            self.startingAddressTextField.text = start
        }
        if let end = UserDefaults.standard.string(forKey: "endingAddress") {
            self.endingAddressTextField.text = end
        }
        if let placemark = LocationManager.shared.placemark {
            guard let dictionary = placemark.addressDictionary as? Dictionary<NSObject,AnyObject> else { return }
            let address = self.localizedStringForAddressDictionary(addressDictionary: dictionary)
            self.address = address
        }
        startingAddressTextField.delegate = self
        endingAddressTextField.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.textFieldShouldReturn))
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        LocationManager.shared.locationManager.delegate = self
        if let placemark = LocationManager.shared.placemark {
            guard let dictionary = placemark.addressDictionary as? Dictionary<NSObject,AnyObject> else { return }
            let address = self.localizedStringForAddressDictionary(addressDictionary: dictionary)
            self.address = address.replacingOccurrences(of: "\n", with: " ", options: .literal, range: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - TextFieldDelegate
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textFieldResignFirstResponder(gesture: UITapGestureRecognizer) {
        startingAddressTextField.resignFirstResponder()
        endingAddressTextField.resignFirstResponder()
    }
    
    // Convert to the newer CNPostalAddress
    func postalAddressFromAddressDictionary(_ addressdictionary: Dictionary<NSObject,AnyObject>) -> CNMutablePostalAddress {
        let address = CNMutablePostalAddress()
        
        address.street = addressdictionary["Street" as NSObject] as? String ?? ""
        address.state = addressdictionary["State" as NSObject] as? String ?? ""
        address.city = addressdictionary["City" as NSObject] as? String ?? ""
        address.country = addressdictionary["Country" as NSObject] as? String ?? ""
        address.postalCode = addressdictionary["ZIP" as NSObject] as? String ?? ""
        
        return address
    }
    
    // Create a localized address string from an Address Dictionary
    func localizedStringForAddressDictionary(addressDictionary: Dictionary<NSObject,AnyObject>) -> String {
        return CNPostalAddressFormatter.string(from: postalAddressFromAddressDictionary(addressDictionary), style: .mailingAddress)
    }
    
    
    // MARK: - Alert controllers
    
    func checkAddressesAlert() {
        let alert = UIAlertController(title: "Check Addresses!", message: "Please check each yardsale in your yardsale list to verify it has an address, city, and state. Check the yardsales that don't have a star in the corner of the picture first. You can click on the yardsale and edit the text boxes to make sure the full address is present. Be sure to hit save in the top right corner!", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
    }
    
    func checkStartEndAlert() {
        let alert = UIAlertController(title: "Check Addresses!", message: "Please check your starting and ending addresses. It appears one of them is blank.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
    }
    
    func troubleShootingAlert() {
        let alert = UIAlertController(title: "Troubleshooting", message: "Did the directions not turn out how you expected? Look at the city and state for each yardsale. Abbreviations won't work for the city name. It needs to have the full city name. Check the address for each yardsale. If the address was mistyped, then it might affect the directions.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
    }
}

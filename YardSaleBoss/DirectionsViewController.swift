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

class DirectionsViewController: UIViewController, CLLocationManagerDelegate  {
    
    var address: String?
    
    @IBOutlet weak var startingAddressTextField: UITextField!
    @IBOutlet weak var endingAddressTextField: UITextField!
    
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
    
    // MARK: - CLLocationManagerDelegate
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error)-> Void in
//            if error != nil {
//                print("Reverse geocoder failed.")
//                return
//            }
//            if let placemarks = placemarks {
//                if placemarks.count > 0 {
//                    let placemark = placemarks[0]
//                    guard let dictionary = placemark.addressDictionary as? Dictionary<NSObject,AnyObject> else { return }
//                    let address = self.localizedStringForAddressDictionary(addressDictionary: dictionary)
//                    self.address = address
//                    self.view.reloadInputViews()
//                }else{
//                    print("No placemarks found.")
//                }
//            }
//        })
//    }
    
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
        let alert = UIAlertController(title: "Check Addresses!", message: "Please check each yardsale in your yardsale list to verify it has an address, city, and state. You can click on the yardsale and edit the text boxes to make sure the full address is present. Be sure to hit save in the top right corner!", preferredStyle: .alert)
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
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

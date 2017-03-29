//
//  DirectionsViewController.swift
//  YardSaleBoss
//
//  Created by Jeremiah Hawks on 3/21/17.
//  Copyright © 2017 Jeremiah Hawks. All rights reserved.
//

import UIKit

class DirectionsViewController: UIViewController {

    @IBOutlet weak var startingAddressTextField: UITextField!
    @IBOutlet weak var endingAddressTextField: UITextField!
    
    @IBAction func directionsButtonTapped(_ sender: Any) {
        if let startingAddress = startingAddressTextField.text, let endingAddress = endingAddressTextField.text {
            for yardsale in YardsaleController.shared.savedYardsales {
                guard yardsale.streetAddress != nil else {
                    self.checkAddressesAlert()
                    self.tabBarController?.selectedIndex = 1
                    return
                }
            }
            if startingAddress != "" && endingAddress != "" {
                User.startAddress = startingAddress.replacingOccurrences(of: ",", with: " ")
                User.endAddress = endingAddress.replacingOccurrences(of: ",", with: " ")
                UserDefaults.standard.set(startingAddress.replacingOccurrences(of: ",", with: " "), forKey: "startingAddress")
                UserDefaults.standard.set(endingAddress.replacingOccurrences(of: ",", with: " "), forKey: "endingAddress")
                UserDefaults.standard.synchronize()
            } else {
                self.checkStartEndAlert()
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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

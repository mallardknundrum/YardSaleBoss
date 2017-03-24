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
            if startingAddress != "" && endingAddress != "" {
                User.startAddress = startingAddress.replacingOccurrences(of: ",", with: "")
                User.endAddress = endingAddress.replacingOccurrences(of: ",", with: "")
            }
        }
        GoogleDirectionsController.shared.fetchGoogleMapsLink()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

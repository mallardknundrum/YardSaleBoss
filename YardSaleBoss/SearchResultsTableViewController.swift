//
//  SearchResultsTableViewController.swift
//  YardSaleBoss
//
//  Created by Jeremiah Hawks on 3/13/17.
//  Copyright © 2017 Jeremiah Hawks. All rights reserved.
//

import UIKit


class SearchResultsTableViewController: UITableViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var zipcodeTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var searchRadiusTextField: UITextField!
    
    
    var yardsales: [Yardsale]? {
        didSet {
            SearchResultsTableViewController.sharedYardsales = yardsales
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    static var sharedYardsales: [Yardsale]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        YardsaleController.shared.fetchYardsales(zipcode: "84116", andDistance: "20") { (yardsaleArray) in
//            self.yardsales = yardsaleArray
//            print("Success!")
//        }
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.superview!.backgroundColor = UIColor.white
        let insets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        self.view.frame = UIEdgeInsetsInsetRect(self.view.superview!.bounds, insets)
    }
    
    // MARK: - Search Function
    @IBAction func searchButtonTapped(_ sender: Any) {
        var zipcode = ""
        var city = ""
        var state = ""
        var searchRadius = ""
        if zipcodeTextField.text != nil {
            zipcode = zipcodeTextField.text!
        }
        if cityTextField.text != nil {
            city = cityTextField.text!
        }
        if stateTextField.text != nil {
            state = stateTextField.text!
        }
        if searchRadiusTextField.text != nil {
            searchRadius = searchRadiusTextField.text!
        }
        YardsaleController.shared.fetchYardsales(withCity: city, state: state, zipcode: zipcode, andDistance: searchRadius) { (yardsaleArray) in
            self.yardsales = yardsaleArray
        }
        view.endEditing(true)
        tableView.reloadData()
    }
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let yardsales = yardsales else { return 0 }
        return yardsales.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultCell", for: indexPath) as? SearchResultsTableViewCell else { return UITableViewCell() }
        cell.yardsale = yardsales?[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}

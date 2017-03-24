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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
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
            guard let stateText = stateTextField.text else { return }
            if stateText.characters.count == 2 && stateText != "  " {
                state = stateText.uppercased()
            } else {
                stateTextField.text = ""
                // pop up alert to ask for UT, ID, or WY
            }
        }
        if searchRadiusTextField.text != nil {
            searchRadius = searchRadiusTextField.text!
        }
        YardsaleController.shared.fetchYardsales(withCity: city, state: state, zipcode: zipcode, andDistance: searchRadius) { (yardsaleArray) in
            YardsaleController.shared.yardsales = yardsaleArray
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        view.endEditing(true)
    }
    
    // MARK: - Table view data source
    
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
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = YardsaleController.shared.yardsales.count - 1
        guard YardsaleController.shared.kslNextPageURLString != "" else { return }
        if indexPath.row == lastElement {
            YardsaleController.shared.kslNextPage(completion: { (yardsales) in
                YardsaleController.shared.yardsales.append(contentsOf: yardsales)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            })
        }
    }
}

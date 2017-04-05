//
//  SavedYardsalesTableViewController.swift
//  YardSaleBoss
//
//  Created by Jeremiah Hawks on 3/16/17.
//  Copyright © 2017 Jeremiah Hawks. All rights reserved.
//

import UIKit

class SavedYardsalesTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let savedYS = UserDefaults.standard.array(forKey: "savedYardSaleIDs") as? [String] {
            User.savedYardsaleIDs = savedYS
        }
        tableView.reloadData()
        self.navigationController?.navigationBar.tintColor = UIColor(colorLiteralRed: 232.0 / 255.0, green: 232.0 / 255.0, blue: 232.0 / 255.0, alpha: 1.0)
        self.navigationController?.navigationBar.backgroundColor = UIColor(colorLiteralRed: 232.0 / 255.0, green: 232.0 / 255.0, blue: 232.0 / 255.0, alpha: 1.0)
        self.navigationController?.navigationBar.barTintColor = UIColor(colorLiteralRed: 232.0 / 255.0, green: 232.0 / 255.0, blue: 232.0 / 255.0, alpha: 1.0)
        
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        self.view.superview!.backgroundColor = UIColor.white
//        let insets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
//        self.view.frame = UIEdgeInsetsInsetRect(self.view.superview!.bounds, insets)
//    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return YardsaleController.shared.savedYardsales.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "savedYardsaleCell", for: indexPath) as? SavedYardsalesTableViewCell else { return UITableViewCell() }
        cell.yardsale = YardsaleController.shared.savedYardsales[indexPath.row]
        cell.layer.cornerRadius = 10
        cell.layer.borderWidth = 2.0
        cell.layer.borderColor = (UIColor(colorLiteralRed: 142.0 / 255, green: 141.0 / 255, blue: 141.0 / 255, alpha: 1)).cgColor
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let yardsale = YardsaleController.shared.savedYardsales[indexPath.row]
            if yardsale.streetAddress == nil {
                YardsaleController.shared.yardsales.insert(yardsale, at: 0)
            }
            YardsaleController.shared.savedYardsales.remove(at: indexPath.row)
            if User.savedYardsaleIDs.contains(yardsale.kslID) {
                if let index = User.savedYardsaleIDs.index(of: yardsale.kslID) {
                    User.savedYardsaleIDs.remove(at: index)
                    UserDefaults.standard.set(User.savedYardsaleIDs, forKey: "savedYardsaleIDs")
                    print(User.savedYardsaleIDs.description)
                    UserDefaults.standard.synchronize()
                }
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let dvc = segue.destination as? DetailViewController else { return }
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        let yardsale = YardsaleController.shared.savedYardsales[indexPath.row]
        dvc.yardsale = yardsale
        let backItem = UIBarButtonItem()
        backItem.title = "Cancel"
        navigationItem.backBarButtonItem = backItem
    }
}

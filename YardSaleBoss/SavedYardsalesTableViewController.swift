//
//  SavedYardsalesTableViewController.swift
//  YardSaleBoss
//
//  Created by Jeremiah Hawks on 3/16/17.
//  Copyright © 2017 Jeremiah Hawks. All rights reserved.
//

import UIKit

class SavedYardsalesTableViewController: UITableViewController {
    
    // MARK: - Actions
    
    @IBAction func clearButtonTapped(_ sender: Any) {
        YardsaleController.shared.savedYardsales = []
        tableView.reloadData()
    }
    
    
    // MARK: - Outlets
    
    @IBOutlet weak var clearButton: UIBarButtonItem!
    
    
    // MARK: - Properties
    
    var showTutorial = false
    var dummyYardsale = Yardsale(title: "Mock Yardsale", yardsaleDescription: "This is a demonstration yardsale. Normally people would post the address of the yardsale here. Here is a sample address: \n\n Address: 301 S Temple, Salt Lake City, UT. You will need to copy the street address and paste it in the address box above. Also, check the city and state. No abbreviations are allowed for the city. For example, SLC will not work. It needs to say Salt Lake City (capitalization is not important). ", yardsaleURL: "www.someRandomYardsale.com", imageURL: "www.randomimage.com", timeOnSite: "30min", cityStateString: "Salt Lake City, UT", image: #imageLiteral(resourceName: "dummyYardsale"), kslID: "gibberish")
    
    
    // MARK: - Tableview lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        if let showTutorial = UserDefaults.standard.object(forKey: "showSavedListTutorial") as? Bool {
            self.showTutorial = showTutorial
            UserDefaults.standard.set(showTutorial, forKey: "showSavedListTutorial")
        } else {
            self.showTutorial = true
            UserDefaults.standard.set(true, forKey: "showSavedListTutorial")
        }
        if self.showTutorial {
            YardsaleController.shared.savedYardsales.insert(dummyYardsale, at: 0)
        }
        clearButton.tintColor = .red
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.showTutorial {
            TutorialController.shared.searchTutorial(viewController: self, title:  "You made it to the second tab! Congratulations!", message: "In this tab, you can view the yardsales that you have saved. If you change your mind about a yardsale, you can swipe to delete it. \n\nClick on a yardsale to see the detail!", alertActionTitle: "Show me the yardsale details", completion: {
                UserDefaults.standard.set(false, forKey: "showSavedListTutorial")
                self.showTutorial = false
                if let index = YardsaleController.shared.savedYardsales.index(of: self.dummyYardsale) {
                    YardsaleController.shared.savedYardsales.remove(at: index)
                }
                self.performSegue(withIdentifier: "toYardsaleDetail", sender: self)
                
            })
        }
    }
    
    
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

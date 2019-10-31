//
//  TutorialController.swift
//  YardSaleBoss
//
//  Created by Jeremiah Hawks on 4/5/17.
//  Copyright © 2017 Jeremiah Hawks. All rights reserved.
//

import UIKit

class TutorialController {
  static let shared = TutorialController()
  var shouldPresentTutorial = true

  func searchTutorial(viewController: UIViewController, title: String, message: String, alertActionTitle: String,  completion: @escaping () -> Void) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let showMeTheNextTab = UIAlertAction(title: alertActionTitle, style: .cancel) { (_) in
      completion()
    }
    alert.addAction(showMeTheNextTab)
    viewController.present(alert, animated: true)
  }

  func changeTabs(viewController:UIViewController, toIndex: Int) {
    viewController.tabBarController?.selectedIndex = toIndex
  }
}

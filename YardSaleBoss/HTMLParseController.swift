//
//  HTMLParseController.swift
//  YardSaleBoss
//
//  Created by Jeremiah Hawks on 3/13/17.
//  Copyright © 2017 Jeremiah Hawks. All rights reserved.
//

import UIKit
import HTMLReader

//class HTMLParseController {
//    
//    static var shared = HTMLParseController()
//    
//    var listings: [Yardsale] = []
//    let baseURL = URL(string: "http://www.ksl.com/classifieds/search/")
//    let parameters = ["keyword": "", "category%5B%5D": "Announcements&subCategory%5B%5D=Garage%2C+Estate%2C+%26+Yard+Sales", "priceFrom": "", "priceTo": "", "city": "", "state": "UT", "zip": "", "miles": "25", "sort": "0"]
//
//    let backSlashCharacterSet = CharacterSet(charactersIn: "\u{005C}")
//    
//    let url = URL(string: "http://www.ksl.com/classifieds/search/?keyword=&category%5B%5D=Announcements&subCategory%5B%5D=Garage%2C+Estate%2C+%26+Yard+Sales&priceFrom=&priceTo=&city=&state=UT&zip=&miles=25&sort=0")
//    
//    func fetchYardsalesWithURL() {
//        let session = URLSession.shared
//        guard let url = url  else { return }
//        let dataTask = session.dataTask(with: url) { (data, _, error) in
//            if let error = error {
//                print("There was an error fetching the data \n \(error.localizedDescription)")
//            }
//            guard let data = data, let dataString = String(data: data, encoding: String.Encoding.utf8) else { return }
//            let doc = HTMLDocument(string: dataString)
//
//            let listingsHTMLElementArray = doc.nodes(matchingSelector: "div[class^='listing-group'] > div[class^='listing']")
//            
//            for yardsale in listingsHTMLElementArray {
//                guard let imagePathEnd = (yardsale.nodes(matchingSelector: "div.photo > a > img")[0].attributes["src"]) else { return }
//                let imagePath = "http:" + imagePathEnd
//                guard let adPathEnd = yardsale.nodes(matchingSelector: "h2 > a")[0].attributes["href"] else { return }
//                let adpath = "http://ksl.com" + adPathEnd
//                let yardSaleDescription = yardsale.nodes(matchingSelector: "div.description.listing-detail-line > div")[0].textContent.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: self.backSlashCharacterSet)
//                guard let cityState = yardsale.firstNode(matchingSelector: "div.listing-detail-line > span.address")?.textContent.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
//                let title = yardsale.nodes(matchingSelector: "h2")[0].textContent.trimmingCharacters(in: .whitespacesAndNewlines)
//                guard let timeOnSite = yardsale.firstNode(matchingSelector: "div.listing-detail-line > span.timeOnSite")?.textContent.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
//                let yardsale = Yardsale(title: title, yardsaleDescription: yardSaleDescription, yardsaleURL: adpath, imageURL: imagePath, timeOnSite: timeOnSite, cityStateString: cityState)
//                self.listings.append(yardsale)
//            }
//        }
//        dataTask.resume()
//    }
//}

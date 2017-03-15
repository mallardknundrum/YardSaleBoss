//
//  HTMLParseController.swift
//  YardSaleBoss
//
//  Created by Jeremiah Hawks on 3/13/17.
//  Copyright © 2017 Jeremiah Hawks. All rights reserved.
//

import UIKit
//import Kanna
//import Alamofire
import HTMLReader


//import SwiftyJSON




class HTMLParseController {
    
    static var shared = HTMLParseController()

    
    let URLString = "http://www.ksl.com/classifieds/search/?keyword=&category%5B%5D=Announcements&subCategory%5B%5D=Garage%2C+Estate%2C+%26+Yard+Sales&priceFrom=&priceTo=&city=&state=UT&zip=&miles=25&sort=0"
    
    var listings: [Yardsale] = []

    let forwardSlashCharacterSet = CharacterSet(charactersIn: "\\")
    
    let url = NSURL(string: "http://www.ksl.com/classifieds/search/?keyword=&category%5B%5D=Announcements&subCategory%5B%5D=Garage%2C+Estate%2C+%26+Yard+Sales&priceFrom=&priceTo=&city=&state=UT&zip=&miles=25&sort=0")
    var dataString:String = ""
    
    func fetchYardsalesWithURL() {
        let session = URLSession.shared
        guard let url = url as? URL else { return }
        let dataTask = session.dataTask(with: url) { (data, _, error) in
            if let error = error {
                print("There was an error fetching the data \n \(error.localizedDescription)")
            }
            if let data = data, let string = String(data: data, encoding: String.Encoding.utf8) {
//                print(string)
                self.dataString = string
            }
            let doc = HTMLDocument(string: self.dataString)
//            let docx = Kanna.HTML(html: self.dataString, encoding: String.Encoding.utf8)
//            guard let docxUnwrapped = docx else { return }
//            for listing in docxUnwrapped.xpath("//listing-group | //listing") {
//                print(listing.text)
//            }
//            var listingGroups = doc.nodes(matchingSelector: "div[class^='listing-group']")
            var testListings = doc.nodes(matchingSelector: "div[class^='listing-group'] > div[class^='listing']")
//            var listingsIndexCount = listingGroups.count - 1
//            var yardsaleArray: [HTMLElement] = []

            
//            while listingsIndexCount >= 0 {
//                let index = listingsIndexCount
//                let singleListingsGroup = listingGroups[index]
//                var singleListingsGroupIndex = singleListingsGroup.children.count - 1
//                while singleListingsGroupIndex >= 0 {
//                    let listingsIndex = singleListingsGroupIndex
//                    if let yardsale = singleListingsGroup.child(at: UInt(listingsIndex)) as? HTMLElement {
//                        yardsaleArray.append(yardsale)
//                    }
//                    singleListingsGroupIndex -= 1
//                }
//                listingsIndexCount -= 1
//            }
            

            
            for yardsale in testListings {
                guard let imagePathEnd = (yardsale.nodes(matchingSelector: "div.photo > a > img")[0].attributes["src"]) else { return }
                let imagePath = "http:" + imagePathEnd
                guard let adPathEnd = yardsale.nodes(matchingSelector: "h2 > a")[0].attributes["href"] else { return }
                let adpath = "http://ksl.com" + adPathEnd
                let yardSaleDescription = yardsale.nodes(matchingSelector: "div.description.listing-detail-line > div")[0].textContent.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: self.forwardSlashCharacterSet)
                guard let cityState = yardsale.firstNode(matchingSelector: "div.listing-detail-line > span.address")?.textContent.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
                let title = yardsale.nodes(matchingSelector: "h2")[0].textContent.trimmingCharacters(in: .whitespacesAndNewlines)
                guard let timeOnSite = yardsale.firstNode(matchingSelector: "div.listing-detail-line > span.timeOnSite")?.textContent.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
                let yardsale = Yardsale(title: title, yardsaleDescription: yardSaleDescription, yardsaleURL: adpath, imageURL: imagePath, timeOnSite: timeOnSite, cityStateString: cityState)
                self.listings.append(yardsale)
                print(title)
            }
        }
        dataTask.resume()
    }
}

//
//  YardsaleController.swift
//  YardSaleBoss
//
//  Created by Jeremiah Hawks on 3/15/17.
//  Copyright © 2017 Jeremiah Hawks. All rights reserved.
//

import Foundation
import HTMLReader

class YardsaleController {
  static let shared = YardsaleController()
  var yardsales: [Yardsale] = []
  var savedYardsales: [Yardsale] = []
  var kslNextPageURLString = ""
  let backSlashCharacterSet = CharacterSet(charactersIn: "\u{005C}")

  func fetchYardsales(withCity city: String = "", state: String = "", zipcode: String = "", andDistance distance: String = "", completion: @escaping ([Yardsale]) -> Void) {
    let urlString = ("http://www.ksl.com/classifieds/search/?keyword=&category%5B%5D=Announcements&subCategory%5B%5D=Garage%2C+Estate%2C+%26+Yard+Sales&priceFrom=&priceTo=&city=\(city)&state=\(state)&zip=\(zipcode)&miles=\(distance)&sort=0").replacingOccurrences(of: " ", with: "%20")
    guard let url = URL(string: urlString) else { completion ([]); return }

    NetworkController.performRequest(for: url, httpMethod: .Get, urlParameters: nil, body: nil) { (data, error) in
      if let error = error {
        print(error.localizedDescription)
        completion([])
        return
      }
      guard let data = data, let dataString = String(data: data, encoding: .utf8) else { completion([]); return }
      let doc = HTMLDocument(string: dataString)
      self.setKSLNextPageURLFor(htmlDocument: doc)
      let listingsHTMLElementArray = doc.nodes(matchingSelector: "div[class^='listing-group'] > div[class^='listing']")
      let listings = self.parseListingElementsFor(elementsArray: listingsHTMLElementArray)

      let group = DispatchGroup()
      for yardsale in listings {
        group.enter()
        ImageController.image(forURL: yardsale.imageURL, completion: { (image) in
          yardsale.image = image
          group.leave()
        })
      }
      group.notify(queue: DispatchQueue.main, execute: {
        completion(listings)
      })
      return
    }
  }

  func kslNextPage(completion: @escaping ([Yardsale]) -> Void) {
    if kslNextPageURLString != "" {
      guard let url = URL(string: kslNextPageURLString) else { completion([]) ; return }
      NetworkController.performRequest(for: url, httpMethod: .Get, urlParameters: nil, body: nil, completion: { (data, error) in
        if let error = error {
          print(error.localizedDescription)
          return
        }
        guard let data = data, let dataString = String(data: data, encoding: .utf8) else { completion([]); return }
        let doc = HTMLDocument(string: dataString)
        self.setKSLNextPageURLFor(htmlDocument: doc)
        let listingsHTMLElementArray = doc.nodes(matchingSelector: "div[class^='listing-group'] > div[class^='listing']")
        let listings = self.parseListingElementsFor(elementsArray: listingsHTMLElementArray)

        let group = DispatchGroup()
        for yardsale in listings {
          group.enter()
          ImageController.image(forURL: yardsale.imageURL, completion: { (image) in
            yardsale.image = image
            group.leave()
          })
        }
        group.notify(queue: DispatchQueue.main, execute: {
          completion(listings)
        })
        return
      })
    }
  }

  func setKSLNextPageURLFor(htmlDocument: HTMLDocument) {
    let nextPageURlStringNode = htmlDocument.nodes(matchingSelector: "body > div.ksl-assets-container.ddm-menu-container > div.inner.ddm-menu-container__inner > div.content.ddm-menu-container__content > div.page-wrap > div.search-results-footer > div.pagination > a.next.link")
    if nextPageURlStringNode.count != 0 {
      if let urlString = nextPageURlStringNode[0].attributes["href"] {
        self.kslNextPageURLString = "http://www.ksl.com" + urlString
      }
    } else {
      self.kslNextPageURLString = ""
    }
  }

  func parseListingElementsFor(elementsArray: [HTMLElement]) -> [Yardsale] {
    var listings: [Yardsale] = []
    for yardsale in elementsArray {
      guard let imagePathEnd = (yardsale.nodes(matchingSelector: "div.photo > a > img")[0].attributes["src"]) else { return [] }
      var imagePath = ""
      if imagePathEnd == "/classifieds/images/responsive/noimage-bike-400x300.png"	{
        imagePath = "http://www.ksl.com" + imagePathEnd
      } else {
        imagePath = "http:" + imagePathEnd
      }
      guard var kslID = yardsale.attributes["data-item-id"] else { return [] }
      kslID = "KSL" + kslID
      guard let adPathEnd = yardsale.nodes(matchingSelector: "h2 > a")[0].attributes["href"] else { return [] }
      let adpath = "http://ksl.com" + adPathEnd
      let yardSaleDescription = yardsale.nodes(matchingSelector: "div.description.listing-detail-line > div")[0].textContent.replacingOccurrences(of: "\tmore", with: "", options: .literal, range: nil).trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: self.backSlashCharacterSet)
      guard let cityState = yardsale.firstNode(matchingSelector: "div.listing-detail-line > span.address")?.textContent.trimmingCharacters(in: .whitespacesAndNewlines) else { return [] }
      let title = yardsale.nodes(matchingSelector: "h2")[0].textContent.trimmingCharacters(in: .whitespacesAndNewlines)
      guard let timeOnSite = yardsale.firstNode(matchingSelector: "div.listing-detail-line > span.timeOnSite")?.textContent.trimmingCharacters(in: .whitespacesAndNewlines) else { return  [] }
      let yardsale = Yardsale(title: title, yardsaleDescription: yardSaleDescription, yardsaleURL: adpath, imageURL: imagePath, timeOnSite: timeOnSite, cityStateString: cityState, kslID: kslID)
      listings.append(yardsale)
    }
    return listings
  }
}

//
//  GoogleDirectionsController.swift
//  YardSaleBoss
//
//  Created by Jeremiah Hawks on 3/17/17.
//  Copyright © 2017 Jeremiah Hawks. All rights reserved.
//

import UIKit

class GoogleDirectionsController {
  let apiKey = "AIzaSyCAuo2kcaz9Oi6YcaSSFdogOlRQdrDYalA"
  let baseURL = "https://maps.googleapis.com/maps/api/directions/json?"
  var googleMapsLink = ""
  static let shared = GoogleDirectionsController()

  func getWaypoints() -> [String] {
    var waypoints: [String] = ["optimize:true"]
    for yardsale in YardsaleController.shared.savedYardsales {
      if let streetAddress = yardsale.streetAddress?.replacingOccurrences(of: " ", with: "+") {
        let waypoint = streetAddress + "+" + yardsale.city.replacingOccurrences(of: " ", with: "+") + "+" + yardsale.state
        waypoints.append(waypoint)
      }
    }
    return waypoints
  }

  func buildRequestURL() -> String {
    var request: String {
      //            guard let origin = User.startAddress else { return "" }
      //            guard let destination = User.endAddress else { return "" }
      let origin = User.startAddress.replacingOccurrences(of: " ", with: "+")
      let destination = User.endAddress.replacingOccurrences(of: " ", with: "+")
      let waypoints = "&waypoints=\(getWaypoints().joined(separator: "|"))"
      let requestURL = baseURL + "origin=\(origin)" + "&destination=\(destination)" + waypoints + "&key=\(apiKey)"
      print(requestURL)
      return requestURL
    }
    return request
  }

  func reorderYardsales(withIndexes indexes:[Int]) -> [Yardsale] {
    var yardsales: [Yardsale] = []
    for (i) in indexes {
      yardsales.append(YardsaleController.shared.savedYardsales[i])
    }
    return yardsales
  }

  func buildGoogleMapsLink(withYardsales yardsales: [Yardsale]) -> String {
    var URL = "https://WWW.google.com/maps/dir/"
    URL += User.startAddress.replacingOccurrences(of: " ", with: "+") + "/"
    for yardsale in yardsales {
      guard let streetAddress = yardsale.streetAddress else { return "" }
      URL += streetAddress.replacingOccurrences(of: " ", with: "+") + ","
      URL += yardsale.city.replacingOccurrences(of: " ", with: "+") + ","
      URL += yardsale.state + "/"
    }
    URL += User.endAddress.replacingOccurrences(of: " ", with: "+")
    return URL
  }

  func fetchGoogleMapsLink() {
    let requestURLString = buildRequestURL()
    guard let url = URL(string: requestURLString.replacingOccurrences(of: "+", with: "%20").replacingOccurrences(of: "|", with: "%7C").replacingOccurrences(of: "–", with: "%2D")) else {
      print(requestURLString)
      return
    }
    NetworkController.performRequest(for: url, httpMethod: .Get, urlParameters: nil, body: nil) { (data, error) in
      if let error = error {
        print("There was an error with the fetchGoogleMapsLink function. \n \(error.localizedDescription)")
        return
      }
      guard let data = data else {
        print("There was no data. \n \(error?.localizedDescription)")
        return
      }
      guard let jsonDictionary = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [String:Any] else { return }
      guard let routesArray = jsonDictionary["routes"] as? [Any] else { return }
      guard let route = routesArray[0] as? [String: Any] else { return }
      guard let indexes = route["waypoint_order"] as? [Int] else { return }
      let yardsalesReordered = self.reorderYardsales(withIndexes: indexes)
      self.googleMapsLink = self.buildGoogleMapsLink(withYardsales: yardsalesReordered).replacingOccurrences(of: "+", with: "%20")
      if let url = URL(string: self.googleMapsLink) {
        UIApplication.shared.open(url)
      }
      print(self.googleMapsLink)
    }
  }
  // TODO: write function to pop up notification to user to set up start and end points if buildRequestURL() = ""
}

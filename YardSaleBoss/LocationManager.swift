//
//  LocationManager.swift
//  YardSaleBoss
//
//  Created by Jeremiah Hawks on 3/30/17.
//  Copyright © 2017 Jeremiah Hawks. All rights reserved.
//

import Foundation
import CoreLocation
import NotificationCenter

class LocationManager: NSObject, CLLocationManagerDelegate {
  static let shared = LocationManager()
  var locationManager = CLLocationManager()
  var placemark: CLPlacemark? {
    didSet {
      NSLog("placemark set")
    }
  }

  override init() {
    super.init()
    if CLLocationManager.authorizationStatus() == .notDetermined {
      locationManager.requestWhenInUseAuthorization()
    }
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
    self.locationManager.distanceFilter = 200
    self.locationManager.delegate = self
    startUpdatingLocation()
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    locationManager.stopUpdatingLocation()
    print(error)
  }

  func startUpdatingLocation() {
    print("Starting Location Updates")
    self.locationManager.startUpdatingLocation()
  }

  func stopUpdatingLocation() {
    print("Stop Location Updates")
    self.locationManager.stopUpdatingLocation()
  }
}

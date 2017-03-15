//
//  Yardsale.swift
//  YardSaleBoss
//
//  Created by Jeremiah Hawks on 3/13/17.
//  Copyright © 2017 Jeremiah Hawks. All rights reserved.
//

import Foundation

class Yardsale {
    
    let title: String
    let yardsaleDescription: String
    let yardsaleURL: String
    let imageURL: String
    let timeOnSite: String
    let cityStateString: String
    var streetAddress: String?
    var city: String?
    var state: String?
    var timestamp: String?
    var zipcode: Int?
    var gpsCoordLat: Float?
    var gpsCoordLong: Float?
    var photoPaths: [String]?
    var yardsaleDate: Date?
//    var reviews: [Review]?
    
    init(title: String, yardsaleDescription: String, yardsaleURL: String, imageURL: String, timeOnSite: String, cityStateString: String, streetAddress: String? = nil, city: String? = nil, state: String? = nil, timestamp: String? = nil, zipcode: Int? = nil, gpsCoordLat: Float? = nil, gpsCoordLong: Float? = nil, photoPaths: [String]? = nil, yardsaleDate: Date? = nil) {
        self.title = title
        self.yardsaleDescription = yardsaleDescription
        self.yardsaleURL = yardsaleURL
        self.imageURL = imageURL
        self.timeOnSite = timeOnSite
        self.cityStateString = cityStateString
        self.streetAddress = streetAddress
        self.city = city
        self.state = state
        self.timestamp = timestamp
        self.zipcode = zipcode
        self.gpsCoordLat = gpsCoordLat
        self.gpsCoordLong = gpsCoordLong
        self.photoPaths = photoPaths
        self.yardsaleDate = yardsaleDate
    }
    
    
    
    
    
}

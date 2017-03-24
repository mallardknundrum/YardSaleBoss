//
//  Yardsale.swift
//  YardSaleBoss
//
//  Created by Jeremiah Hawks on 3/13/17.
//  Copyright © 2017 Jeremiah Hawks. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

class Yardsale: Equatable {
    
    let title: String
    let yardsaleDescription: String
    let yardsaleURL: String
    let imageURL: String
    let timeOnSite: String
    var cityStateString: String
    let kslID: String
    var streetAddress: String?
    var image: UIImage?
    var city: String {
        return cityStateString.components(separatedBy: ", ")[0]
    }
    var state: String {
        return cityStateString.components(separatedBy: ", ")[1]
    }
    var timestamp: String?
    var zipcode: Int?
    var gpsCoordLat: Float?
    var gpsCoordLong: Float?
    var photoPaths: [String]?
    var yardsaleDate: Date?
//    var reviews: [Review]?
    
    init(title: String, yardsaleDescription: String, yardsaleURL: String, imageURL: String, timeOnSite: String, cityStateString: String, streetAddress: String? = nil, image: UIImage? = nil, timestamp: String? = nil, zipcode: Int? = nil, gpsCoordLat: Float? = nil, gpsCoordLong: Float? = nil, photoPaths: [String]? = nil, yardsaleDate: Date? = nil, kslID: String) {
        self.title = title
        self.yardsaleDescription = yardsaleDescription
        self.yardsaleURL = yardsaleURL
        self.imageURL = imageURL
        self.timeOnSite = timeOnSite
        self.image = image
        self.cityStateString = cityStateString
        self.streetAddress = streetAddress
        self.timestamp = timestamp
        self.zipcode = zipcode
        self.gpsCoordLat = gpsCoordLat
        self.gpsCoordLong = gpsCoordLong
        self.photoPaths = photoPaths
        self.yardsaleDate = yardsaleDate
        self.kslID = kslID
    }
}

extension Yardsale {
    static func == (lhs: Yardsale, rhs: Yardsale) -> Bool {
        return lhs.kslID == rhs.kslID
    }
}

extension CKRecord {
    convenience init(_ yardsale: Yardsale) {
        let recordID = CKRecordID(recordName: yardsale.kslID)
        self.init(recordType: "Yardsale", recordID: recordID)
        
    }
}

//
//  Yardsale.swift
//  YardSaleBoss
//
//  Created by Jeremiah Hawks on 3/13/17.
//  Copyright © 2017 Jeremiah Hawks. All rights reserved.
//

import UIKit
import CloudKit

class Yardsale: Equatable {
  // MARK: - Keys
  static let titleKey = "title"
  static let yardsaleDescriptionKey = "yardsaleDescripiton"
  static let yardsaleURLKey = "yardsaleURL"
  static let imageURLKey = "imageURL"
  static let timeOnSiteKey = "timeOnSite"
  static let kslIDKey = "kslID"
  static let streetAddressKey = "streetAddress"
  static let imageKey = "image"
  static let cityStateStringKey = "cityStateString"

  // MARK: - Properties
  let title: String
  let yardsaleDescription: String
  let yardsaleURL: String
  let imageURL: String
  let timeOnSite: String
  var cityStateString: String
  let kslID: String
  var streetAddress: String?
  var image: UIImage?
  var imageCKAsset: CKAsset? {
    do {
      guard let image = image else { return nil}
      let data = image.pngData()
      let tempDirectory = NSURL.fileURL(withPath: NSTemporaryDirectory(), isDirectory: true)
      let assetName = "defaultImage"
      let tempURL = tempDirectory.appendingPathComponent("\(assetName).png")
      try data?.write(to: tempURL, options: .atomicWrite)
      return CKAsset(fileURL: tempURL)
    }
    catch {
      print("Error writing data", error)
      return nil
    }
  }

  var city: String {
    return cityStateString.components(separatedBy: ", ")[0]
  }

  var state: String {
    return cityStateString.components(separatedBy: ", ")[1]
  }

  var timestamp: Date?
  var zipcode: Int?
  var gpsCoordLat: Float?
  var gpsCoordLong: Float?
  var photoPaths: [String]?
  var yardsaleDate: Date?
  //    var reviews: [Review]?

  init(title: String,
       yardsaleDescription: String,
       yardsaleURL: String,
       imageURL: String,
       timeOnSite: String,
       cityStateString: String,
       streetAddress: String? = nil,
       image: UIImage? = nil,
       timestamp: Date? = nil,
       zipcode: Int? = nil,
       gpsCoordLat: Float? = nil,
       gpsCoordLong: Float? = nil,
       photoPaths: [String]? = nil,
       yardsaleDate: Date? = nil,
       kslID: String) {

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

  init?(withCKRecord CKRecord: CKRecord) {
    guard let title = CKRecord[Yardsale.titleKey] as? String,
      let description = CKRecord[Yardsale.yardsaleDescriptionKey] as? String,
      let url = CKRecord[Yardsale.yardsaleURLKey] as? String,
      let imageURL = CKRecord[Yardsale.imageURLKey] as? String,
      let cityState = CKRecord[Yardsale.cityStateStringKey] as? String,
      let imageAsset = CKRecord[Yardsale.imageKey] as? CKAsset,
      let timeOnSite = CKRecord[Yardsale.timeOnSiteKey] as? String,
      let streetAddress = CKRecord[Yardsale.streetAddressKey] as? String
      else { return nil }

    self.title = title
    self.yardsaleDescription = description
    self.yardsaleURL = url
    self.imageURL = imageURL
    self.cityStateString = cityState
    var image: UIImage? = nil

    do {
      // TODO: Discuss whether optional binding should be in the do-catch block.
      if let url = imageAsset.fileURL {
        let imageData = try Data(contentsOf: url)
        image = UIImage(data: imageData)
      }
    } catch {
      print("Error turning imageAsset into UIImage")
    }

    self.image = image
    self.timeOnSite = timeOnSite
    self.kslID = String(describing: CKRecord.recordID.recordName)
    self.timestamp = CKRecord.creationDate
    self.streetAddress = streetAddress
    self.zipcode = nil
    self.gpsCoordLat = nil
    self.gpsCoordLong = nil
    self.photoPaths = nil
    self.yardsaleDate = nil
  }
}

// MARK: - Equatable
extension Yardsale {
  static func == (lhs: Yardsale, rhs: Yardsale) -> Bool {
    return lhs.yardsaleURL == rhs.yardsaleURL
  }
}

// MARK: - CKRecord extension (convenience init)
extension CKRecord {
  convenience init(_ yardsale: Yardsale) {
    let recordID = CKRecord.ID(recordName: yardsale.kslID)
    self.init(recordType: "Yardsale", recordID: recordID)
    self.setValue(yardsale.title, forKey: Yardsale.titleKey)
    self.setValue(yardsale.yardsaleDescription, forKey: Yardsale.yardsaleDescriptionKey)
    self.setValue(yardsale.yardsaleURL, forKey: Yardsale.yardsaleURLKey)
    self.setValue(yardsale.imageURL, forKey: Yardsale.imageURLKey)
    self.setValue(yardsale.timeOnSite, forKey: Yardsale.timeOnSiteKey)
    self.setValue(yardsale.imageCKAsset, forKey: Yardsale.imageKey)
    self.setValue(yardsale.cityStateString, forKey: Yardsale.cityStateStringKey)
    self.setValue(yardsale.streetAddress, forKey: Yardsale.streetAddressKey)
  }
}

//
//  User.swift
//  YardSaleBoss
//
//  Created by Jeremiah Hawks on 3/17/17.
//  Copyright © 2017 Jeremiah Hawks. All rights reserved.
//

import Foundation
import CloudKit
import CoreData

class User {
    static var startAddress = ""
    static var endAddress = ""
    static var savedYardsaleIDs: [String] = []
}

//extension User {
//    convenience init(startAddress: String, endAddress: String, savedYardsaleIDs: String, context: NSManagedObjectContext = CoreDataStack.context) {
//        self.init(context: context)
//        self.startAddress = startAddress
//        self.endAddress = endAddress
//        self.savedYardsales: savedYardsales
//    }
//}

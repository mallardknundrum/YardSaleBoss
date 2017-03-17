//
//  User.swift
//  YardSaleBoss
//
//  Created by Jeremiah Hawks on 3/17/17.
//  Copyright © 2017 Jeremiah Hawks. All rights reserved.
//

import Foundation
import CloudKit

class User {
    var startAddress: String?
    var endAddress: String?
    var savedYardsales: [CKReference] = []
}

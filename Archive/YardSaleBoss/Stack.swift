//
//  Stack.swift
//  YardSaleBoss
//
//  Created by Jeremiah Hawks on 3/13/17.
//  Copyright © 2017 Jeremiah Hawks. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    
    //TODO: understand every line of this file. write comments.
    static let container: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "YardSaleBossCoreData")
        container.loadPersistentStores() { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    static var context: NSManagedObjectContext { return container.viewContext }
}

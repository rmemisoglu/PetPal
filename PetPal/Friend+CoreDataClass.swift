//
//  Friend+CoreDataClass.swift
//  PetPal
//
//  Created by Ramazan Memişoğlu on 8.08.2019.
//  Copyright © 2019 Razeware. All rights reserved.
//
//

import Foundation
import CoreData


public class Friend: NSManagedObject {
    
    var age: Int {
        if let dob = dob as? Date {
            return Calendar.current.dateComponents([.year], from: dob, to:Date()).year!
        }
        return 0
    }
}

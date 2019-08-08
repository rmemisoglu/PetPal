//
//  Friend+CoreDataProperties.swift
//  PetPal
//
//  Created by Ramazan Memişoğlu on 8.08.2019.
//  Copyright © 2019 Razeware. All rights reserved.
//
//

import Foundation
import CoreData


extension Friend {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Friend> {
        return NSFetchRequest<Friend>(entityName: "Friend")
    }

    @NSManaged public var name: String?
    @NSManaged public var address: String?
    @NSManaged public var dob: NSDate?
    @NSManaged public var eyeColor: NSObject?

}

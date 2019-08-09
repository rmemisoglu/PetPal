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
import UIKit

public class Friend: NSManagedObject {
    
    var eyeColorString: String {
        guard let color = eyeColor as? UIColor else {
            return "No Color"
        }
        switch color {
            case UIColor.black: return "Black"
            case UIColor.blue: return "Blue"
            case UIColor.brown: return "Brown"
            case UIColor.green: return "Green"
            //case UIColor.gray: return "Gray"
        default: return "Unknown"
            
        }
    }
    
    var age: Int {
        if let dob = dob as Date? {
            return Calendar.current.dateComponents([.year], from: dob, to:Date()).year!
        }
        return 0
    }
}

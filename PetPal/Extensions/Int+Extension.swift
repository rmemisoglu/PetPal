//  Created by Ramazan Memişoğlu on 8.08.2019.
//  Copyright © 2019 Razeware. All rights reserved.

import Foundation

extension Int {
	func random() -> Int {
		let isNegative = self < 0
		let random = Int(arc4random_uniform(UInt32(abs(self)))) * (isNegative ? -1 : 1)
		return random
	}
}

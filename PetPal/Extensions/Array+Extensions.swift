//  Created by Ramazan Memişoğlu on 8.08.2019.
//  Copyright © 2019 Razeware. All rights reserved.

import Foundation

extension Array {
	func random() -> Element? {
		if self.isEmpty {
			return nil
		}
		let index = self.count.random()
		return self[index]
	}
}

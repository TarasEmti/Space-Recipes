//
//  String Localized.swift
//  Space Recipes
//
//  Created by Тарас on 12.03.2018.
//  Copyright © 2018 Taras Minin. All rights reserved.
//

import Foundation

extension String {
	
	func localized(withComment comment: String) -> String {
		return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: comment)
	}
	
	var localized: String {
		return self.localized(withComment: "")
	}
}

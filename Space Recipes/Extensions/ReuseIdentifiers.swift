//
//  ReuseIdentifiers.swift
//  Space Recipes
//
//  Created by Тарас on 12.03.2018.
//  Copyright © 2018 Taras Minin. All rights reserved.
//

import UIKit

protocol ReuseIdetifiable: class {
	static func reuseIdentifier() -> String
}

extension ReuseIdetifiable {
	static func reuseIdentifier() -> String {
		return NSStringFromClass(self)
	}
}

extension UITableViewCell: ReuseIdetifiable { }
extension UICollectionViewCell: ReuseIdetifiable { }

//
//  UIView + Ext.swift
//  Space Recipes
//
//  Created by Тарас on 12.03.2018.
//  Copyright © 2018 Taras Minin. All rights reserved.
//

import UIKit

protocol NibCompatible: class {
	static func nib() -> UINib
}

extension UIView: NibCompatible {
	static func nib() -> UINib {
		return nib(forType: self)
	}
}

extension UIView {
	func loadFromNib() -> UIView {
		let name = UIView.nibName(forType: self.classForCoder)
		return loadFromNibNamed(name)
	}
	
	func loadFromNibNamed(_ name: String) -> UIView {
		
		guard let view = Bundle.main.loadNibNamed(name, owner: self, options: nil)?.last
			as? UIView else {
				fatalError("Can not load view named \(name)")
		}
		addSubview(view)
		return view
	}
}

private extension UIView {
	static func nib(forType type: Swift.AnyClass) -> UINib {
		let nibName = self.nibName(forType: type)
		let bundle = Bundle(for: type)
		let nib = UINib(nibName: nibName, bundle: bundle)
		return nib
	}
	
	static func nibName(forType type: Swift.AnyClass) -> String {
		let fullTypeName = NSStringFromClass(type)
		
		let nameComponents = fullTypeName.components(separatedBy: ".")
		if let lastNameComponent = nameComponents.last {
			return lastNameComponent
		} else {
			return fullTypeName
		}
	}
}

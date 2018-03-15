//
//  SRInsetsLabel.swift
//  Space Recipes
//
//  Created by Taras Minin on 15.03.2018.
//  Copyright © 2018 Taras Minin. All rights reserved.
//

import UIKit

class SRInsetsLabel: UILabel {

	var insets: UIEdgeInsets = .zero

	override var intrinsicContentSize: CGSize {
		let size = super.intrinsicContentSize
		let newSize = CGSize(width: size.width + insets.left + insets.right, height: size.height + insets.bottom + insets.top)
		
		return newSize
	}
}

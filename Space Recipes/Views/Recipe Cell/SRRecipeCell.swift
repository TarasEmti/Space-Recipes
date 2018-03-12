//
//  SRRecipeCell.swift
//  Space Recipes
//
//  Created by Тарас on 12.03.2018.
//  Copyright © 2018 Taras Minin. All rights reserved.
//

import UIKit

class SRRecipeCell: UITableViewCell {

	@IBOutlet weak var recipeImageView: UIImageView!
	@IBOutlet weak var recipeName: UILabel!
	@IBOutlet weak var recipeDetails: UILabel!
	
	override func awakeFromNib() {
        super.awakeFromNib()
		
		recipeName.font = SRLib.headerFont
		recipeDetails.font = SRLib.commonFont
    }

	func fillWithObject(recipe: SRRecipe) {
		recipeImageView.image = #imageLiteral(resourceName: "icon_placeholder")
		recipeName.text = recipe.name
		recipeDetails.text = recipe.details
	}
}

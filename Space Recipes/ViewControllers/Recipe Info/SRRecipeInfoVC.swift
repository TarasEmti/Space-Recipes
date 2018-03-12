//
//  SRRecipeInfoVC.swift
//  Space Recipes
//
//  Created by Тарас on 12.03.2018.
//  Copyright © 2018 Taras Minin. All rights reserved.
//

import UIKit

class SRRecipeInfoVC: UIViewController {
	
	@IBOutlet weak var recipeImagesScrollView: UIScrollView!
	@IBOutlet weak var recipeName: UILabel!
	@IBOutlet weak var recipeDetails: UILabel!
	@IBOutlet weak var recipeInstruction: UITextView!
	@IBOutlet weak var recipeDifficulty: UILabel!
	@IBOutlet weak var imagesPageControl: UIPageControl!
	
	var recipe: SRRecipe?

    override func viewDidLoad() {
        super.viewDidLoad()

		setupOutlets()
		if let recipe = recipe {
			self.title = "Recipe".localized
			setupView(withRecipe: recipe)
		}
    }
	
	private func setupOutlets() {
		recipeName.font = SRLib.headerFont
		recipeDetails.font = SRLib.commonFont
		recipeDifficulty.font = SRLib.hintFont
		recipeInstruction.font = SRLib.commonFont
		recipeInstruction.isEditable = false
	}
	
	// Kind of ViewModel module here
	private func setupView(withRecipe recipe: SRRecipe) {
		recipeName.text = recipe.name
		recipeDetails.text = recipe.details
		recipeInstruction.text = recipe.cookingInstructions
		
		var difficultyString = "Difficulty: ".localized
		let difficultyInt = recipe.difficultyLevel.rawValue
		for i in 1...5 {
			if i <= difficultyInt {
				difficultyString += "⭐️"
			} else {
				difficultyString += " ●"
			}
		}
		recipeDifficulty.text = difficultyString
	}
}

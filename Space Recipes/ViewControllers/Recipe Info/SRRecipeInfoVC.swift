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
	@IBOutlet weak var pageCounter: UILabel!
	
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
		recipeDifficulty.backgroundColor = UIColor.white.withAlphaComponent(0.8)
		recipeDifficulty.layer.cornerRadius = 6
		recipeDifficulty.clipsToBounds = true
		recipeInstruction.font = SRLib.commonFont
		recipeInstruction.isEditable = false
		
		guard let recipe = recipe else {
			return
		}
		self.recipeImagesScrollView.contentSize.width = self.recipeImagesScrollView.bounds.width * CGFloat(recipe.images.count)
		for i in 0 ..< recipe.images.count {
			let imageView = UIImageView()
			imageView.contentMode = .scaleAspectFill
			let xOffset = CGFloat(i) * self.view.bounds.width
			imageView.frame = CGRect(x: xOffset,
									 y: 0,
									 width: self.recipeImagesScrollView.frame.width,
									 height: self.recipeImagesScrollView.frame.height)
			self.recipeImagesScrollView.addSubview(imageView)
			if recipe.images[i] == nil, let imageURL = URL(string: recipe.imagesStrings[i]) {
				
				imageView.image = #imageLiteral(resourceName: "icon_placeholder")
				
				ImageLoader.loadImage(fromUrl: imageURL, completion: { (image, _) in
					if image != nil {
						imageView.image = image
					}
				})
			} else {
				imageView.image = recipe.images[i]
			}
		}
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
			}
		}
		recipeDifficulty.text = difficultyString
	}
}

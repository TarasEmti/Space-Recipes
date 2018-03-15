//
//  SRRecipeInfoVC.swift
//  Space Recipes
//
//  Created by Тарас on 12.03.2018.
//  Copyright © 2018 Taras Minin. All rights reserved.
//

import UIKit

class SRRecipeInfoVC: UIViewController {
	
	@IBOutlet private weak var recipeImagesScrollView: UIScrollView!
	@IBOutlet private weak var recipeName: UILabel!
	@IBOutlet private weak var recipeDetails: UILabel!
	@IBOutlet private weak var recipeInstruction: UITextView!
	@IBOutlet private weak var recipeDifficulty: SRInsetsLabel!
	@IBOutlet private weak var pageCounter: SRInsetsLabel!
	
	@IBOutlet private weak var instructionTextViewHeight: NSLayoutConstraint!
	@IBOutlet weak var instructionToDetails: NSLayoutConstraint!
	@IBOutlet weak var instructionToName: NSLayoutConstraint!
	
	private var recipeImageViews = [UIImageView]()
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
		
		recipeDifficulty.insets = UIEdgeInsetsMake(5, 10, 5, 10)
		recipeDifficulty.font = SRLib.hintFont
		recipeDifficulty.backgroundColor = UIColor.white.withAlphaComponent(0.8)
		recipeDifficulty.layer.cornerRadius = 6
		recipeDifficulty.clipsToBounds = true
		
		pageCounter.insets = UIEdgeInsetsMake(5, 10, 5, 10)
		pageCounter.font = SRLib.hintFont
		pageCounter.backgroundColor = UIColor.white.withAlphaComponent(0.8)
		pageCounter.layer.cornerRadius = 6
		pageCounter.clipsToBounds = true
		
		recipeInstruction.font = SRLib.commonFont
		recipeInstruction.isEditable = false
		
		guard let recipe = recipe else {
			return
		}
		
		for _ in 0 ..< recipe.images.count {
			let imageView = UIImageView()
			imageView.contentMode = .scaleAspectFill
			imageView.image = #imageLiteral(resourceName: "icon_placeholder")
			recipeImageViews.append(imageView)
			recipeImagesScrollView.addSubview(imageView)
		}
		
		for i in 0 ..< recipe.images.count {
			if recipe.images[i] == nil, let imageURL = URL(string: recipe.imagesStrings[i]) {
				ImageLoader.loadImage(fromUrl: imageURL, completion: { [weak self] (image, _) in
					
					guard let strongSelf = self else {
						return
					}
					if image != nil {
						strongSelf.recipe!.images[i] = image
						strongSelf.recipeImageViews[i].image = image
						strongSelf.view.setNeedsLayout()
						strongSelf.view.layoutIfNeeded()
					}
				})
			} else {
				recipeImageViews[i].image = recipe.images[i]
			}
		}
		recipeImagesScrollView.delegate = self
		pageCounter.text = String(format: "1/%d", recipe.images.count)
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		let imageWidth: CGFloat = view.bounds.width
		for i in 0 ..< recipeImageViews.count {
			let xOffset = CGFloat(i) * imageWidth
			recipeImageViews[i].frame = CGRect(x: xOffset,
									 y: 0,
									 width: imageWidth,
									 height: recipeImagesScrollView.bounds.height)
		}
		recipeImagesScrollView.contentSize.width = imageWidth * CGFloat(recipeImageViews.count)
		instructionTextViewHeight.constant = recipeInstruction.contentSize.height
	}
	
	// Kind of ViewModel module here
	private func setupView(withRecipe recipe: SRRecipe) {
		recipeName.text = recipe.name
		if recipe.details.isEmpty {
			recipeDetails.isHidden = true
			instructionToName.priority = .defaultHigh
			instructionToDetails.priority = .defaultLow
		} else {
			recipeDetails.text = recipe.details
			recipeDetails.isHidden = false
			instructionToName.priority = .defaultLow
			instructionToDetails.priority = .defaultHigh
		}
		//recipeInstruction.text = recipe.cookingInstructions
		
		if let contentData = recipe.cookingInstructions.data(using: String.Encoding.utf16),
			let attributedText = try? NSAttributedString(data: contentData,
														 options: [.documentType: NSAttributedString.DocumentType.html,
																   ],
														 documentAttributes: nil) {
			recipeInstruction.attributedText = attributedText
		} else {
			recipeInstruction.text = recipe.cookingInstructions
		}
		
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

extension SRRecipeInfoVC: UIScrollViewDelegate {
	
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		let pageFloat = round(scrollView.contentOffset.x / scrollView.frame.size.width)
		let pageNum = Int(pageFloat) + 1
		self.pageCounter.text = "\(Int(pageNum))/\(recipe!.images.count)"
	}
}

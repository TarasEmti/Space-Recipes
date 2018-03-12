//
//  SRRecipe.swift
//  Space Recipes
//
//  Created by Тарас on 12.03.2018.
//  Copyright © 2018 Taras Minin. All rights reserved.
//

import Foundation

enum RecipeDifficulty: Int {
	case easy = 1
	case ordinary
	case medium
	case hard
	case impossible
}

struct SRRecipeJSON: Decodable {
	let recipes: [SRRecipe]
}

struct SRRecipe {
	var uuid: String
	var lastUpdated: Int
	var images: [String]
	var name: String
	var details: String
	var cookingInstructions: String
	var difficultyLevel: RecipeDifficulty
	
	var icon: String {
		return images.first ?? ""
	}
}

extension SRRecipe: Decodable {
	
	enum CodingKeys: String, CodingKey {
		case uuid
		case name
		case images
		case lastUpdated
		case details = "description"
		case cookingInstructions = "instructions"
		case difficultyLevel = "difficulty"
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		uuid = try container.decode(String.self, forKey: .uuid)
		name = try container.decode(String.self, forKey: .name)
		images = try container.decode([String].self, forKey: .images)
		lastUpdated = try container.decode(Int.self, forKey: .lastUpdated)
		// We assume that details is not a required parameter (because 8825cde8-630a-4027-9b9c-38b34bd4426b recipe don't have it)
		details = (try? container.decode(String.self, forKey: .details)) ?? ""
		cookingInstructions = try container.decode(String.self, forKey: .cookingInstructions)
		let difficulty = try container.decode(Int.self, forKey: .difficultyLevel)
		difficultyLevel = RecipeDifficulty(rawValue: difficulty) ?? .easy
	}
}

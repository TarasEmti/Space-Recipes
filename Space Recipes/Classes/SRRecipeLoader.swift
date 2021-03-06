//
//  SRRecipeLoader.swift
//  Space Recipes
//
//  Created by Тарас on 12.03.2018.
//  Copyright © 2018 Taras Minin. All rights reserved.
//

import Foundation

enum SRServerErrorKind: Int {
	case unknown		= 0
	case unauthorised 	= 401
	case notFound 		= 404
	case internalError 	= 500
	
	var message: String {
		let errorDescription: String
		switch self {
		case .notFound:
			errorDescription = "Not Found".localized
		case .unauthorised:
			errorDescription = "Bad Access".localized
		case .internalError:
			errorDescription = "Server Error".localized
		case .unknown:
			errorDescription = "Unknown Error".localized
		}
		return errorDescription
	}
}

struct SRParserError: Error {
	let message: String
}

struct SRLoaderError: Error {
	let kind: SRServerErrorKind
}

final class SRRecipeLoader {
	
	func loadRecipes(completion: @escaping ([SRRecipe]?, Error?) -> Void) {
		
		guard let url = URL(string: SRLib.recipeUrl) else {
			let error = SRLoaderError(kind: .notFound)
			completion(nil, error)
			return
		}
		let task = URLSession.shared.dataTask(with: url) { (data, _, error) in
			
			var recipes: [SRRecipe]?
			var taskError: Error?
			
			guard let data = data, error == nil else {
				let taskError = error ?? SRParserError(message: "No data response".localized)
				completion(recipes, taskError)
				return
			}
			do {
				let decoder = JSONDecoder()
				let recipeJSON = try decoder.decode(SRRecipeJSON.self, from: data)
				recipes = recipeJSON.recipes
			} catch {
				let parserError = SRParserError(message: "Bad data format".localized)
				taskError = parserError
			}
			completion(recipes, taskError)
		}
		task.resume()
	}
}

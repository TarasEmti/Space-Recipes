//
//  ImageLoader.swift
//  Space Recipes
//
//  Created by Тарас on 14.03.2018.
//  Copyright © 2018 Taras Minin. All rights reserved.
//

import UIKit

class ImageLoader {
	
	class func loadImage(fromUrl url: URL, completion: @escaping (UIImage?, Error?) -> Void) {
		
		let task = URLSession.shared.dataTask(with: url) { (imageData, _, error) in
			var output: UIImage?
			if imageData != nil, let image = UIImage(data: imageData!) {
				output = image
			}
			DispatchQueue.main.async {
				completion(output, error)
			}
		}
		task.resume()
	}
}

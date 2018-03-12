//
//  SRRecipesTableVC.swift
//  Space Recipes
//
//  Created by Тарас on 12.03.2018.
//  Copyright © 2018 Taras Minin. All rights reserved.
//

import UIKit

fileprivate enum RecipeSearchFilters: String {
	case name
	case details
	case instruction
	
	var title: String {
		
		let title: String
		switch self {
		case .name:
			title = "Name".localized
		case .details:
			title = "Details".localized
		case .instruction:
			title = "Instruction".localized
		}
		return title
	}
}

class SRRecipesTableVC: UITableViewController {
	
	private var recipes: [SRRecipe] = [SRRecipe]() {
		didSet {
			tableView.reloadData()
		}
	}
	private var filteredRecipes: [SRRecipe]!
	private let recipeLoader = SRRecipeLoader()
	private let searchController = UISearchController(searchResultsController: nil)
	
	// MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
		
		setupView()
		setupTableView()
		setupSearchController()
    }
	
	private func setupView() {
		self.title = "Choose Recipe".localized
		self.clearsSelectionOnViewWillAppear = false
		reloadRecipes()
	}
	
	private func setupTableView() {
		tableView.register(SRRecipeCell.nib(), forCellReuseIdentifier: SRRecipeCell.reuseIdentifier())
		tableView.refreshControl = UIRefreshControl()
		tableView.refreshControl?.addTarget(self, action: #selector(reloadRecipes), for: .valueChanged)
		tableView.keyboardDismissMode = .onDrag
	}
	
	private func setupSearchController() {
		searchController.searchResultsUpdater = self
		searchController.searchBar.scopeButtonTitles = [RecipeSearchFilters.name.title,
														RecipeSearchFilters.details.title,
														RecipeSearchFilters.instruction.title]
		searchController.obscuresBackgroundDuringPresentation = false
		searchController.searchBar.placeholder = "Search recipes".localized
		searchController.searchBar.delegate = self
		if #available(iOS 11.0, *) {
			navigationItem.searchController = searchController
			navigationItem.hidesSearchBarWhenScrolling = true
		} else {
			tableView.tableHeaderView = searchController.searchBar
		}
		definesPresentationContext = true
	}
	
	// MARK: - Search Controller
	private func searchBarIsEmpty() -> Bool {
		return searchController.searchBar.text?.isEmpty ?? true
	}
	
	private func isFiltering() -> Bool {
		return searchController.isActive && !searchBarIsEmpty()
	}
	
	fileprivate func filterContentForSearchText(searchText: String, scope: String = "All") {
		filteredRecipes = recipes.filter { (recipe: SRRecipe) -> Bool in
			
			let text: String
			
			switch scope {
			case RecipeSearchFilters.name.title:
				text = recipe.name.lowercased()
			case RecipeSearchFilters.details.title:
				text = recipe.details.lowercased()
			case RecipeSearchFilters.instruction.title:
				text = recipe.cookingInstructions.lowercased()
			default:
				return true
			}
			return text.contains(searchText.lowercased())
		}
		tableView.reloadData()
	}
	
	// MARK: - Actions
	@objc func reloadRecipes() {
		recipeLoader.loadRecipes { [weak self] (recipes, error) in
			
			guard let strongSelf = self else {
				return
			}
			DispatchQueue.main.async {
				if error != nil {
					print(error.debugDescription)
				} else if recipes != nil {
					strongSelf.recipes = recipes!
				}
				if strongSelf.tableView.refreshControl!.isRefreshing {
					strongSelf.tableView.refreshControl?.endRefreshing()
				}
			}
		}
	}

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let numberOfRows: Int
		if isFiltering() {
			numberOfRows = filteredRecipes.count
		} else {
			numberOfRows = recipes.count
		}
        return numberOfRows
    }

	// MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SRRecipeCell.reuseIdentifier(), for: indexPath) as? SRRecipeCell else {
			return UITableViewCell()
		}
		let recipe: SRRecipe
		if isFiltering() {
			recipe = filteredRecipes[indexPath.row]
		} else {
			recipe = recipes[indexPath.row]
		}
		cell.fillWithObject(recipe: recipe)
		
        return cell
    }
}

// MARK: - Extensions
// MARK: UISearchResultsUpdating
extension SRRecipesTableVC: UISearchResultsUpdating {
	
	func updateSearchResults(for searchController: UISearchController) {
		
		let searchBar = searchController.searchBar
		let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
		if let text = searchBar.text {
			filterContentForSearchText(searchText: text, scope: scope)
		}
	}
}

// MARK: UISearchBarDelegate
extension SRRecipesTableVC: UISearchBarDelegate {
	
	func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
		if let text = searchBar.text, let scopeTitles = searchBar.scopeButtonTitles {
			filterContentForSearchText(searchText: text, scope: scopeTitles[selectedScope])
		}
	}
}

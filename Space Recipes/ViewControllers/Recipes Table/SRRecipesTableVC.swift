//
//  SRRecipesTableVC.swift
//  Space Recipes
//
//  Created by Тарас on 12.03.2018.
//  Copyright © 2018 Taras Minin. All rights reserved.
//

import UIKit

fileprivate enum SortType {
	case date
	case name
	
	var title: String {
		switch self {
		case .date:
			return "Date".localized
		case .name:
			return "Name".localized
		}
	}
}

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
	private let sortTypes = [SortType.date, SortType.name]
	
	// MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
		
		setupView()
		setupTableView()
		setupSearchController()
		setupSegmentedControl()
    }
	
	private func setupView() {
		self.title = "Choose Recipe".localized
		self.clearsSelectionOnViewWillAppear = true
		reloadRecipes()
	}
	
	private func setupTableView() {
		tableView.register(SRRecipeCell.nib(), forCellReuseIdentifier: SRRecipeCell.reuseIdentifier())
		tableView.refreshControl = UIRefreshControl()
		tableView.refreshControl?.addTarget(self, action: #selector(reloadRecipes), for: .valueChanged)
		tableView.keyboardDismissMode = .onDrag
		// Calculating rowHeight which is depend on screen height
		let rowHeight = self.view.bounds.height / 8
		tableView.rowHeight = rowHeight
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
	
	private func setupSegmentedControl() {
		let sortTypesTitles = self.sortTypes.map{ $0.title }
		let segControl = UISegmentedControl(items: sortTypesTitles)
		segControl.addTarget(self, action: #selector(sortRecipes(sender:)), for: .valueChanged)
		navigationItem.titleView = segControl
		segControl.selectedSegmentIndex = 0
	}
	
	@objc private func sortRecipes(sender: UISegmentedControl) {
		let sortType = self.sortTypes[sender.selectedSegmentIndex]
		
		switch  sortType {
		case .date:
			self.recipes = self.recipes.sorted(by: { $0.lastUpdated > $1.lastUpdated })
		case .name:
			self.recipes = self.recipes.sorted(by: { $0.name < $1.name })
		}
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
		
		// Enshure we are not in a search state
		guard !isFiltering() else {
			tableView.refreshControl?.endRefreshing()
			return
		}
		recipeLoader.loadRecipes { [weak self] (recipes, error) in
			
			guard let strongSelf = self else {
				return
			}
			if error != nil {
				// TODO: Show error in HUD
				print(error.debugDescription)
			} else if recipes != nil {
				DispatchQueue.main.async {
					strongSelf.setRecipes(recipes!)
				}
			}
			
		}
	}
	
	private func setRecipes(_ recipes: [SRRecipe]) {
		self.recipes = recipes
		for i in 0 ..< recipes.count {
			if let iconString = recipes[i].imagesStrings.first,
				let iconURL = URL(string: iconString) {
				ImageLoader.loadImage(fromUrl: iconURL, completion: { [weak self] (image, error) in
					
					guard let strongSelf = self else {
						return
					}
					if error != nil {
						// TODO: Show error in HUD
					} else {
						strongSelf.recipes[i].images[0] = image
						strongSelf.tableView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
					}
				})
			}
		}
		if let refreshControl = tableView.refreshControl, refreshControl.isRefreshing {
			tableView.refreshControl?.endRefreshing()
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
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let recipe: SRRecipe
		if isFiltering() {
			recipe = filteredRecipes[indexPath.row]
		} else {
			recipe = recipes[indexPath.row]
		}
		let recipeView = SRRecipeInfoVC()
		recipeView.recipe = recipe
		
		navigationController?.pushViewController(recipeView, animated: true)
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

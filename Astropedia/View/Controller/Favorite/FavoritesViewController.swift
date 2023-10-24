//
//  FavoritesViewController.swift
//  Astropedia
//
//  Created by Yves Charpentier on 29/04/2023.
//

import Foundation
import UIKit
import Combine

class FavoritesViewController: UIViewController, UISearchBarDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var favoriteLabel: UILabel!
    
    private let favoritesViewModel = FavoritesViewModel()
    private let coreDataStack = CoreDataStack()
    private var cancellables: Set<AnyCancellable> = []
    private let searchController = UISearchController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI(data: favoritesViewModel.$favorites, isFavoriteEmpty: favoritesViewModel.$isEmptyFavorite, favorite: favoriteLabel, tableView: tableView)
        setupSearchController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        favoritesViewModel.fetchFavorite()
        favoritesViewModel.isEmpty()
    }
    
    private final func updateUI(data: Published<[Favorite]>.Publisher, isFavoriteEmpty: Published<Bool?>.Publisher, favorite: UILabel, tableView: UITableView) {
        Publishers.CombineLatest(data, isFavoriteEmpty)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _, isEmpty in
                self?.tableView.reloadData()
                favorite.isHidden = !(isEmpty ?? true)
                tableView.isHidden = isEmpty ?? true
            }
            .store(in: &cancellables)
    }
    
    func navigateToDetailViewController<T>(item: T) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        switch item {
        case let picture as LocalPicture:
            guard let detailPictureVC = storyboard.instantiateViewController(withIdentifier: "DetailPictureViewController") as? DetailPictureViewController else { return }
            detailPictureVC.picture = picture.toPicture()
            self.navigationController?.pushViewController(detailPictureVC, animated: true)
            
        case let article as LocalArticle:
            guard let detailArticleVC = storyboard.instantiateViewController(withIdentifier: "DetailArticleViewController") as? DetailArticleViewController else { return }
            detailArticleVC.article = article.toArticle()
            self.navigationController?.pushViewController(detailArticleVC, animated: true)
            
        default:
            return
        }
    }
    
    private final func setupSearchController() {
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Mot-clé"
        definesPresentationContext = true
    }
    
    @IBAction func dismissFavoritesVC() {
        dismiss(animated: true)
    }
}

extension FavoritesViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return favoritesViewModel.filteredFavorites.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return favoritesViewModel.filteredFavorites[section].name
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoritesViewModel.filteredFavorites[section].data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "pictureCell", for: indexPath) as? FavoritesTableViewCell else {
            return UITableViewCell()
        }
        let favoriteData = favoritesViewModel.filteredFavorites[indexPath.section].data
        if let picture = favoriteData[indexPath.row] as? LocalPicture {
            cell.configure(title: picture.title, image: picture.imageURL, mediaType: picture.mediaType, date: picture.date)
        } else if let article = favoriteData[indexPath.row] as? LocalArticle {
            cell.configure(title: article.title, image: article.image, mediaType: "image", date: "")
        }
        return cell
    }
}

extension FavoritesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let context = coreDataStack.viewContext
        var categoryData = favoritesViewModel.filteredFavorites[indexPath.section].data
        if let picture = categoryData[indexPath.row] as? LocalPicture {
            context.delete(picture)
        } else if let article = categoryData[indexPath.row] as? LocalArticle {
            context.delete(article)
        }
        categoryData.remove(at: indexPath.row)
        favoritesViewModel.filteredFavorites[indexPath.section].data = categoryData
        favoritesViewModel.favorites = favoritesViewModel.favorites.map { favoriteCategory in
            if favoriteCategory.type == favoritesViewModel.filteredFavorites[indexPath.section].type {
                var updatedCategory = favoriteCategory
                updatedCategory.data = categoryData
                return updatedCategory
            } else {
                return favoriteCategory
            }
        }
        do {
            try context.save()
            favoritesViewModel.isEmpty()
        } catch {
            print("Error")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section < favoritesViewModel.filteredFavorites.count else { return }
        guard indexPath.row < favoritesViewModel.filteredFavorites[indexPath.section].data.count else { return }
        let item = favoritesViewModel.filteredFavorites[indexPath.section].data[indexPath.row]
        navigateToDetailViewController(item: item)
    }
}

extension FavoritesViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if searchText.isEmpty {
            favoritesViewModel.filteredFavorites = favoritesViewModel.favorites
        } else {
            let filteredFavorites: [Favorite] = favoritesViewModel.favorites.map { favorite in
                let filteredData: [Any]
                switch favorite.type {
                case .picture:
                    let pictures = favorite.data.compactMap { $0 as? LocalPicture }
                    filteredData = pictures.filter { picture in
                        return picture.title?.localizedStandardContains(searchText) ?? false
                    }
                case .article:
                    let articles = favorite.data.compactMap { $0 as? LocalArticle }
                    filteredData = articles.filter { article in
                        return article.title?.localizedCaseInsensitiveContains(searchText) ?? false
                    }
                }
                return Favorite(name: favorite.name, type: favorite.type, data: filteredData)
            }
            favoritesViewModel.filteredFavorites = filteredFavorites
        }
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        favoritesViewModel.fetchFavorite()
        favoritesViewModel.filteredFavorites = favoritesViewModel.favorites
        tableView.reloadData()
    }

}

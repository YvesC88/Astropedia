//
//  FavoritesViewController.swift
//  Astropedia
//
//  Created by Yves Charpentier on 29/04/2023.
//

import Foundation
import UIKit
import CoreData

class FavoritesViewController: UIViewController, UISearchBarDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var favoriteLabel: UILabel!
    
    private let favoriteService = FavoriteService()
    private let searchController = UISearchController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchController()
        favoriteService.favoriteDelegate = self
        favoriteService.fetchFavoriteData()
        favoriteService.showIsEmpty()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        favoriteService.fetchFavoriteData()
    }
    
    private final func setupSearchController() {
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Rechercher dans vos favoris"
        definesPresentationContext = true
    }
    
    @IBAction func dismissFavoritesVC() {
        dismiss(animated: true)
    }
}

extension FavoritesViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return favoriteService.filteredFavorites.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return favoriteService.filteredFavorites[section].name
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteService.filteredFavorites[section].data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "pictureCell", for: indexPath) as? FavoritesTableViewCell else {
            return UITableViewCell()
        }
        let favoriteData = favoriteService.filteredFavorites[indexPath.section].data
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
        let context = CoreDataStack.share.viewContext
        var categoryData = favoriteService.filteredFavorites[indexPath.section].data
        if let picture = categoryData[indexPath.row] as? LocalPicture {
            context.delete(picture)
            favoriteService.favoritePicture = favoriteService.favoritePicture.filter { $0 != picture }
        } else if let article = categoryData[indexPath.row] as? LocalArticle {
            context.delete(article)
            favoriteService.favoriteArticle = favoriteService.favoriteArticle.filter { $0 != article }
        }
        categoryData.remove(at: indexPath.row)
        favoriteService.filteredFavorites[indexPath.section].data = categoryData
        do {
            try context.save()
            favoriteService.showIsEmpty()
        } catch {
            print("Error")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section < favoriteService.filteredFavorites.count else { return }
        let favoriteCategory = favoriteService.filteredFavorites[indexPath.section]
        guard indexPath.row < favoriteCategory.data.count else { return }
        let selectedItem = favoriteCategory.data[indexPath.row]
        switch favoriteCategory.type {
        case .picture:
            guard let picture = selectedItem as? LocalPicture else { return }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let detailPictureVC = storyboard.instantiateViewController(withIdentifier: "DetailPictureViewController") as? DetailPictureViewController else { return }
            detailPictureVC.picture = picture.toPicture()
            self.navigationController?.pushViewController(detailPictureVC, animated: true)
            
        case .article:
            guard let article = selectedItem as? LocalArticle else { return }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let detailArticleVC = storyboard.instantiateViewController(withIdentifier: "DetailArticleViewController") as? DetailArticleViewController else { return }
            detailArticleVC.article = article.toArticle()
            self.navigationController?.pushViewController(detailArticleVC, animated: true)
        }
    }
}

extension FavoritesViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text?.lowercased(), !searchText.isEmpty {
            let filteredFavorites: [FavoriteCategory] = favoriteService.favorites.compactMap { favorite in
                let filteredData = favorite.data.filter { data in
                    if let picture = data as? LocalPicture, let pictureTitle = picture.title {
                        return pictureTitle.lowercased().hasPrefix(searchText)
                    } else if let article = data as? LocalArticle, let articleTitle = article.title {
                        return articleTitle.lowercased().hasPrefix(searchText)
                    }
                    return false
                }
                if !filteredData.isEmpty {
                    var favoriteCopy = favorite
                    favoriteCopy.data = filteredData
                    return favoriteCopy
                }
                return nil
            }
            favoriteService.filteredFavorites = filteredFavorites
        } else {
            favoriteService.filteredFavorites = favoriteService.favorites
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension FavoritesViewController: FavoriteDelegate {
    
    func showEmptyLabel(isHidden: Bool) {
        tableView.isHidden = isHidden
        favoriteLabel.isHidden = !isHidden
    }
    
    func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

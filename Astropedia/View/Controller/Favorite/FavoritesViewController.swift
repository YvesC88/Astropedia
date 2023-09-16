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
            let pictureData = picture
            cell.configure(title: pictureData.title, image: pictureData.imageURL, mediaType: pictureData.mediaType, date: pictureData.date)
        } else if let article = favoriteData[indexPath.row] as? LocalArticle {
            let articleData = article.toArticle()
            cell.configure(title: articleData.title, image: articleData.image, mediaType: "image", date: "")
        }
        return cell
    }
}

extension FavoritesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let context = CoreDataStack.share.viewContext
        let categoryIndex = indexPath.section
        let itemIndex = indexPath.row
        var categoryData = favoriteService.favorites[categoryIndex].data
        if let picture = categoryData[itemIndex] as? LocalPicture {
            context.delete(picture)
            favoriteService.favoritePicture = favoriteService.favoritePicture.filter { $0 != picture }
        } else if let article = categoryData[itemIndex] as? LocalArticle {
            context.delete(article)
            favoriteService.favoriteArticle = favoriteService.favoriteArticle.filter { $0 != article }
        }
        categoryData.remove(at: itemIndex)
        favoriteService.favorites[categoryIndex].data = categoryData
        do {
            try context.save()
            favoriteService.showIsEmpty()
        } catch {
            print("Error")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let categoryIndex = indexPath.section
        let dataIndex = indexPath.row
        guard categoryIndex < favoriteService.filteredFavorites.count else { return }
        let favoriteCategory = favoriteService.filteredFavorites[categoryIndex]
        guard dataIndex < favoriteCategory.data.count else { return }
        let selectedItem = favoriteCategory.data[dataIndex]
        switch favoriteCategory.type {
        case .picture:
            guard let picture = selectedItem as? LocalPicture else { return }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let detailPictureVC = storyboard.instantiateViewController(withIdentifier: "DetailPictureViewController") as! DetailPictureViewController
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
                    if let picture = data as? LocalPicture {
                        return picture.title!.lowercased().hasPrefix(searchText)
                    } else if let article = data as? LocalArticle {
                        return article.title!.lowercased().hasPrefix(searchText)
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

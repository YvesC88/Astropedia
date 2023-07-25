//
//  FavoritesViewController.swift
//  Planets
//
//  Created by Yves Charpentier on 29/04/2023.
//

import Foundation
import UIKit
import CoreData

class FavoritesViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var favoriteLabel: UILabel!
    
    private let favoriteService = FavoriteService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        favoriteService.favoriteDelegate = self
        favoriteService.fetchFavoriteData()
        favoriteService.showIsEmpty()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        favoriteService.fetchFavoriteData()
        favoriteService.showIsEmpty()
    }
    
    @IBAction func dismissFavoritesVC() {
        dismiss(animated: true)
    }
}

extension FavoritesViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return favoriteService.favorites.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return favoriteService.favorites[section].category
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteService.favorites[section].data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "pictureCell", for: indexPath) as? FavoritesTableViewCell else {
            return UITableViewCell()
        }
        let data = favoriteService.favorites[indexPath.section].data
        
        if let picture = data[indexPath.row] as? LocalPicture {
            let pictureData = picture
            cell.configure(title: pictureData.title, image: pictureData.imageURL, mediaType: pictureData.mediaType)
        } else if let article = data[indexPath.row] as? LocalArticle {
            let articleData = article.toArticle()
            cell.configure(title: articleData.title, image: articleData.image, mediaType: "image")
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
        
        guard categoryIndex < favoriteService.favorites.count else { return }
        
        if categoryIndex == 0 {
            // Picture selected
            guard dataIndex < favoriteService.favoritePicture.count else { return }
            let picture = favoriteService.favoritePicture[dataIndex].toPicture()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let detailPictureVC = storyboard.instantiateViewController(withIdentifier: "DetailPictureViewController") as! DetailPictureViewController
            detailPictureVC.picture = picture
            self.navigationController?.pushViewController(detailPictureVC, animated: true)
        } else if categoryIndex == 1 {
            // Article selected
            guard dataIndex < favoriteService.favoriteArticle.count else { return }
            let article = favoriteService.favoriteArticle[dataIndex].toArticle()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let detailArticleVC = storyboard.instantiateViewController(withIdentifier: "DetailArticleViewController") as? DetailArticleViewController else { return }
            detailArticleVC.article = article
            self.navigationController?.pushViewController(detailArticleVC, animated: true)
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

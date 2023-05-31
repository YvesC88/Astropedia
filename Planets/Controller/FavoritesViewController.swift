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
    
    private var favoritePicture: [LocalPicture] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var favoriteArticle: [LocalArticle] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var favorites: [(category: String, data: [Any])] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var currentLanguage = LanguageSettings.currentLanguage
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
        showLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
        showLabel()
    }
    
    private func showLabel() {
        let isEmpty = favoriteArticle.isEmpty && favoritePicture.isEmpty
        tableView.isHidden = isEmpty
        favoriteLabel.isHidden = !isEmpty
    }
    
    private func fetchData() {
        let pictureRequest: NSFetchRequest<LocalPicture> = LocalPicture.fetchRequest()
        let articleRequest: NSFetchRequest<LocalArticle> = LocalArticle.fetchRequest()
        
        guard let picture = try? CoreDataStack.share.viewContext.fetch(pictureRequest) else { return }
        favoritePicture = picture
        guard let article = try? CoreDataStack.share.viewContext.fetch(articleRequest) else { return }
        favoriteArticle = article
        
        if LanguageSettings.currentLanguage == "fr" {
            favorites = [
                (category: "Mes images", data: favoritePicture),
                (category: "Mes articles", data: favoriteArticle)]
        } else {
            favorites = [
                (category: "My pictures", data: favoritePicture),
                (category: "My articles", data: favoriteArticle)]
        }
        
    }
}

extension FavoritesViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return favorites.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return favorites[section].category
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites[section].data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "pictureCell", for: indexPath) as? FavoritesTableViewCell else {
            return UITableViewCell()
        }
        let data = favorites[indexPath.section].data
        
        if let picture = data[indexPath.row] as? LocalPicture {
            let pictureData = picture.toPicture()
            cell.configure(title: pictureData.title, image: pictureData.image)
        } else if let article = data[indexPath.row] as? LocalArticle {
            let articleData = article.toArticle()
            cell.configure(title: articleData.title, image: articleData.image)
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
        
        var categoryData = favorites[categoryIndex].data
        
        if let picture = categoryData[itemIndex] as? LocalPicture {
            context.delete(picture)
            favoritePicture = favoritePicture.filter { $0 != picture }
        } else if let article = categoryData[itemIndex] as? LocalArticle {
            context.delete(article)
            favoriteArticle = favoriteArticle.filter { $0 != article }
        }
        
        categoryData.remove(at: itemIndex)
        favorites[categoryIndex].data = categoryData
        
        do {
            try context.save()
            showLabel()
        } catch {
            print("Error")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let categoryIndex = indexPath.section
        let dataIndex = indexPath.row
        
        guard categoryIndex < favorites.count else { return }
        
        if categoryIndex == 0 {
            // Picture selected
            guard dataIndex < favoritePicture.count else { return }
            let picture = favoritePicture[dataIndex].toPicture()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let detailPictureVC = storyboard.instantiateViewController(withIdentifier: "DetailPictureViewController") as! DetailPictureViewController
            detailPictureVC.picture = picture
            self.navigationController?.pushViewController(detailPictureVC, animated: true)
        } else if categoryIndex == 1 {
            // Article selected
            guard dataIndex < favoriteArticle.count else { return }
            let article = favoriteArticle[dataIndex].toArticle()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let detailArticleVC = storyboard.instantiateViewController(withIdentifier: "DetailArticleViewController") as? DetailArticleViewController else { return }
            detailArticleVC.article = article
            self.navigationController?.pushViewController(detailArticleVC, animated: true)
        }
    }
}

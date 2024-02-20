//
//  FavoritesViewController.swift
//  Astropedia
//
//  Created by Yves Charpentier on 29/04/2023.
//

import Foundation
import UIKit
import Combine

final class FavoritesViewController: UIViewController, UISearchBarDelegate, UIViewControllerTransitioningDelegate {
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
    
    // La fonction semble cache bcp de pbmatiques. Les parameters n'ont peu de lien tous entre eux, on passe un label avec de la data et un boolean en publisher et meme une table view.. J'ai pas de solution car il me faudrait comprendre ce que tu veux as besoin de faire avec tout ca ici et il me faudrait du temps
    // Autre soucis : updateUI mais derriere on a un sink sur un publisher. Un sink sur un publisher est une souscription. Si aucun de tes publishers de ton CombineLatest ne produit d'output il ne se passera rien. La naming de ta func dit qu'il doit se passer qqchose maintenant avec updateUI. Rien ne le dit d'apres son contenu.
    // Dernier soucis, si tu appelles cette methodes 10x tu auras 10 subscriptions en meme temps... Je suis sur que c'est pas ce que tu souhaites ;)
    private func updateUI(
        data: Published<[Favorite]>.Publisher,
        isFavoriteEmpty: Published<Bool?>.Publisher,
        favorite: UILabel,
        tableView: UITableView
    ) {
        Publishers.CombineLatest(data, isFavoriteEmpty)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _, isEmpty in
                self?.tableView.reloadData()
                favorite.isHidden = !(isEmpty ?? true)
                tableView.isHidden = isEmpty ?? true
                self?.searchController.searchBar.isHidden = isEmpty ?? true
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
            let navController = UINavigationController(rootViewController: detailArticleVC)
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated: true)
            
        default:
            return
        }
    }
    
    private func setupSearchController() {
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Mot-clé" // ViewModel
        definesPresentationContext = true
    }
    
    // Le naming n'est pas bon : il dit que ce doit faire l'action et non qui produit l'action cad un bouton tapped ? Comment faire pour retrouver d'ou vient l'action ? Autre pb, si l'action change tu devras aussi changer le naming de la func et donc reconnecter avec ton storyboard..
    @IBAction private func dismissFavoritesVC() {
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
    
    // Le contenu de la methode est complexe ici. Tu fais bcp de choses differentes on n'a pas envie de la lire pour la comprendre. Essaie de decomposer en sous methodes si besoin. Decomposer en sous methodes permettra d'aider a la comprehension grace au naming de ces methodes. Si elle fait trop de choses c'est souvent qu'il y a un pb.
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
            print("Error") // A eviter si possible ;)
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
                        let pictureTitle = picture.title?.localizedStandardContains(searchText) ?? false
                        let pictureExplanation = picture.explanation?.localizedStandardContains(searchText) ?? false
                        return pictureTitle || pictureExplanation
                    }
                case .article:
                    let articles = favorite.data.compactMap { $0 as? LocalArticle }
                    filteredData = articles.filter { article in
                        let articleTitle = article.title?.localizedStandardContains(searchText) ?? false
                        let articleText = article.articleText?.contains { $0.localizedStandardContains(searchText) } ?? false
                        return articleTitle || articleText
                    }
                }
                return Favorite(name: favorite.name, type: favorite.type, data: filteredData)
            }
            favoritesViewModel.filteredFavorites = filteredFavorites
        }
        // T'es sur d'etre sur le main thread ici ?
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        favoritesViewModel.fetchFavorite()
        favoritesViewModel.filteredFavorites = favoritesViewModel.favorites
        // Idem ici
        tableView.reloadData()
    }
}

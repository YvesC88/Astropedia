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
    
    private var favoritePicture: [LocalPicture] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchLocalPicture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchLocalPicture()
    }
    
    private func fetchLocalPicture() {
        let request: NSFetchRequest<LocalPicture> = LocalPicture.fetchRequest()
        guard let picture = try? CoreDataStack.share.viewContext.fetch(request) else { return }
        favoritePicture = picture
    }
}

extension FavoritesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        favoritePicture.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "pictureCell", for: indexPath) as? FavoriteCell else {
            return UITableViewCell()
        }
        guard indexPath.row < favoritePicture.count else { return cell }
        let picture = favoritePicture[indexPath.row]
        cell.configure(title: picture.title!, image: picture.imageSD!)
        return cell
    }
}

extension FavoritesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let context = CoreDataStack.share.viewContext
        context.delete(favoritePicture[indexPath.row])
        favoritePicture.remove(at: indexPath.row)
        do {
            try context.save()
        } catch {
            print("Error")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        guard indexPath.row < favoritePicture.count else { return }
        let picture = favoritePicture[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let customViewController = storyboard.instantiateViewController(withIdentifier: "DetailFavoriteViewController") as! DetailFavoriteViewController
        customViewController.picture = picture.toPicture()
        self.navigationController?.pushViewController(customViewController, animated: true)
    }
}

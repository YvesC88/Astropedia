//
//  ViewController.swift
//  Planets
//
//  Created by Yves Charpentier on 16/01/2023.
//

import UIKit


class PlanetViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    let searchController = UISearchController()
    
    var planets: [FirebaseData] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    var moons: [FirebaseData] = []
    
    var allData: [FirebaseData] {
        return planets + moons
    }
    
    var filteredData = [FirebaseData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Rechercher dans Astropédia"
        definesPresentationContext = true
        loadPlanets()
        loadMoons()
    }
    
    func loadPlanets() {
        let service = FirebaseDataService(wrapper: FirebaseWrapper())
        service.fetchData(collectionID: "planets") { planet, error in
            for data in planet {
                self.planets.append(data)
            }
        }
    }
    
    func loadMoons() {
        let service = FirebaseDataService(wrapper: FirebaseWrapper())
        service.fetchData(collectionID: "moons") { moon, error in
            for data in moon {
                self.moons.append(data)
            }
        }
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
}

extension PlanetViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredData.count
        }
        return planets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PresentPlanetCell", for: indexPath) as? PresentPlanetCell else {
            return UITableViewCell()
        }
        let data: FirebaseData
        if isFiltering() {
            data = filteredData[indexPath.row]
        } else {
            data = planets[indexPath.row]
        }
        cell.configure(name: data.name, image: data.image, tempMoy: data.tempMoy, membership: data.membership, type: data.type, diameter: data.diameter)
        let info = UIImage(systemName: "chevron.right")
        cell.accessoryType = .detailButton
        cell.accessoryView = UIImageView(image: info)
        cell.accessoryView?.tintColor = UIColor.systemGray
        return cell
    }
}

extension PlanetViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data: FirebaseData
        if isFiltering() {
            if indexPath.row < filteredData.count {
                data = filteredData[indexPath.row]
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let customViewController = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
                customViewController.data = data
                self.navigationController?.pushViewController(customViewController, animated: true)
            }
        } else {
            if indexPath.row < planets.count {
                data = planets[indexPath.row]
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let customViewController = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
                customViewController.data = data
                self.navigationController?.pushViewController(customViewController, animated: true)
            }
        }
    }
}

extension PlanetViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else {
            return
        }
        filteredData = []
        for name in allData {
            if name.name.uppercased().hasPrefix(text.uppercased()) {
                filteredData.append(name)
            }
        }
        tableView.reloadData()
    }
}

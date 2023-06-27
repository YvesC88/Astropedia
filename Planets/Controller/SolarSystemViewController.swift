//
//  ViewController.swift
//  Planets
//
//  Created by Yves Charpentier on 16/01/2023.
//

import UIKit


final class SolarSystemViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak private var tableView: UITableView!
    
    var collection = FirebaseCollection()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchController()
        loadData()
    }
    
    private final func setupSearchController() {
        navigationItem.searchController = SolarSystemViewController.searchController
        SolarSystemViewController.searchController.searchResultsUpdater = self
        SolarSystemViewController.searchController.searchBar.delegate = self
        SolarSystemViewController.searchController.searchBar.placeholder = "Rechercher dans le Système Solaire"
        definesPresentationContext = true
    }
    
    private final func loadData() {
        SolarSystemViewController.service.fetchData(collectionID: "planets") { [weak self] planet, error in
            guard let self = self else { return }
            if let error = error {
                print("Erreur lors du chargement des planètes:", error)
            } else {
                collection.planets = planet
                self.updateSolarSystem()
            }
        }
        
        SolarSystemViewController.service.fetchData(collectionID: "dwarfPlanets") { [weak self] dwarfPlanets, error in
            guard let self = self else { return }
            if let error = error {
                print("Erreur lors du chargement des planètes naines", error)
            } else {
                collection.dwarfPlanets = dwarfPlanets
                self.updateSolarSystem()
            }
        }
        SolarSystemViewController.service.fetchData(collectionID: "moons") { [weak self] moon, error in
            guard let self = self else { return }
            if let error = error {
                print("Erreur lors du chargement des lunes:", error)
            } else {
                collection.moons = moon
                self.updateSolarSystem()
            }
        }
        SolarSystemViewController.service.fetchData(collectionID: "stars") { [weak self] star, error in
            guard let self = self else { return }
            if let error = error {
                print("Erreur lors du chargement des étoiles:", error)
            } else {
                collection.stars = star
                self.updateSolarSystem()
            }
        }
    }
    
    func filterData() {
        if isFiltering() {
            let searchText = SolarSystemViewController.searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() ?? ""
            collection.filteredPlanets = collection.planets.filter { $0.name.uppercased().hasPrefix(searchText) }
            collection.filteredMoons = collection.moons.filter { $0.name.uppercased().hasPrefix(searchText) }
            collection.filteredStars = collection.stars.filter { $0.name.uppercased().hasPrefix(searchText) }
            collection.filteredDwarfPlanets = collection.dwarfPlanets.filter { $0.name.uppercased().hasPrefix(searchText) }
        }
    }
    
    private final func updateSolarSystem() {
        guard !collection.planets.isEmpty, !collection.moons.isEmpty, !collection.stars.isEmpty, !collection.dwarfPlanets.isEmpty else {
            return
        }
        filterData()
        collection.solarSystem = [
            (category: collection.categories[0], data: isFiltering() ? collection.filteredStars : collection.stars),
            (category: collection.categories[1], data: isFiltering() ? collection.filteredPlanets : collection.planets),
            (category: collection.categories[2], data: isFiltering() ? collection.filteredDwarfPlanets : collection.dwarfPlanets),
            (category: collection.categories[3], data: isFiltering() ? collection.filteredMoons : collection.moons)
        ]
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    private final func isFiltering() -> Bool {
        return isSearchBarEmpty(SolarSystemViewController.searchController.searchBar)
    }
    
    private final func isSearchBarEmpty(_ searchBar: UISearchBar) -> Bool {
        return searchBar.text?.isEmpty ?? true
    }
}

extension SolarSystemViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return collection.solarSystem.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return collection.solarSystem[section].category
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collection.solarSystem[section].data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SolarSystemCell", for: indexPath) as? SolarSystemTableViewCell else {
            return UITableViewCell()
        }
        let data = collection.solarSystem[indexPath.section].data[indexPath.row]
        cell.configure(name: data.name, image: data.image, tempMoy: data.tempMoy, sat: data.sat, membership: data.membership, type: data.type, diameter: data.diameter)
        return cell
    }
}

extension SolarSystemViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = collection.solarSystem[indexPath.section].data[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let detailVC = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return }
        detailVC.data = data
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension SolarSystemViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        let filterClosure: (FirebaseData) -> Bool = { data in
            return data.name.uppercased().hasPrefix(searchText.uppercased())
        }
        let filteredPlanets = collection.planets.filter(filterClosure)
        let filteredMoons = collection.moons.filter(filterClosure)
        let filteredStars = collection.stars.filter(filterClosure)
        let filteredDwarfPlanets = collection.dwarfPlanets.filter(filterClosure)
        
        collection.solarSystem = [
            (category: collection.categories[0], data: filteredStars),
            (category: collection.categories[1], data: filteredPlanets),
            (category: collection.categories[2], data: filteredDwarfPlanets),
            (category: collection.categories[3], data: filteredMoons)
        ]
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

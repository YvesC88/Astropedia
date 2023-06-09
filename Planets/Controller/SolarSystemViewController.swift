//
//  ViewController.swift
//  Planets
//
//  Created by Yves Charpentier on 16/01/2023.
//

import UIKit


final class SolarSystemViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak private var tableView: UITableView!
    
    private let searchController = UISearchController()
    private var solarSystem: [(category: String, data: [FirebaseData])] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchController()
        loadData()
    }
    
    private final func setupSearchController() {
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = (LanguageSettings.currentLanguage == "fr") ? LanguageSettings.placeholderFr : LanguageSettings.placeholderEn
        definesPresentationContext = true
    }
    
    private final func loadData() {
        LanguageSettings.service.fetchData(collectionID: LanguageSettings.collectionPlanet) { [weak self] planet, error in
            guard let self = self else { return }
            if let error = error {
                print("Erreur lors du chargement des planètes:", error)
            } else {
                LanguageSettings.planets = planet
                self.updateSolarSystem()
            }
        }
        
        LanguageSettings.service.fetchData(collectionID: LanguageSettings.collectionDwarfPlanet) { [weak self] dwarfPlanets, error in
            guard let self = self else { return }
            if let error = error {
                print("Erreur lors du chargement des planètes naines", error)
            } else {
                LanguageSettings.dwarfPlanets = dwarfPlanets
                self.updateSolarSystem()
            }
        }
        LanguageSettings.service.fetchData(collectionID: LanguageSettings.collectionMoon) { [weak self] moon, error in
            guard let self = self else { return }
            if let error = error {
                print("Erreur lors du chargement des lunes:", error)
            } else {
                LanguageSettings.moons = moon
                self.updateSolarSystem()
            }
        }
        LanguageSettings.service.fetchData(collectionID: LanguageSettings.collectionStar) { [weak self] star, error in
            guard let self = self else { return }
            if let error = error {
                print("Erreur lors du chargement des étoiles:", error)
            } else {
                LanguageSettings.stars = star
                self.updateSolarSystem()
            }
        }
    }
    
    func filterData() {
        if isFiltering() {
            let searchText = searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() ?? ""
            LanguageSettings.filteredPlanets = LanguageSettings.planets.filter { $0.name.uppercased().hasPrefix(searchText) }
            LanguageSettings.filteredMoons = LanguageSettings.moons.filter { $0.name.uppercased().hasPrefix(searchText) }
            LanguageSettings.filteredStars = LanguageSettings.stars.filter { $0.name.uppercased().hasPrefix(searchText) }
            LanguageSettings.filteredDwarfPlanets = LanguageSettings.dwarfPlanets.filter { $0.name.uppercased().hasPrefix(searchText) }
        }
    }
    
    private final func updateSolarSystem() {
        guard !LanguageSettings.planets.isEmpty, !LanguageSettings.moons.isEmpty, !LanguageSettings.stars.isEmpty, !LanguageSettings.dwarfPlanets.isEmpty else {
            return
        }
        filterData()
        solarSystem = [
            (category: LanguageSettings.categories[0], data: isFiltering() ? LanguageSettings.filteredStars : LanguageSettings.stars),
            (category: LanguageSettings.categories[1], data: isFiltering() ? LanguageSettings.filteredPlanets : LanguageSettings.planets),
            (category: LanguageSettings.categories[2], data: isFiltering() ? LanguageSettings.filteredDwarfPlanets : LanguageSettings.dwarfPlanets),
            (category: LanguageSettings.categories[3], data: isFiltering() ? LanguageSettings.filteredMoons : LanguageSettings.moons)
        ]
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    private final func isFiltering() -> Bool {
        return isSearchBarEmpty(searchController.searchBar)
    }

    private final func isSearchBarEmpty(_ searchBar: UISearchBar) -> Bool {
        return searchBar.text?.isEmpty ?? true
    }
}

extension SolarSystemViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return solarSystem.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return solarSystem[section].category
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return solarSystem[section].data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SolarSystemCell", for: indexPath) as? SolarSystemTableViewCell else {
            return UITableViewCell()
        }
        let data = solarSystem[indexPath.section].data[indexPath.row]
        cell.configure(name: data.name, image: data.image, tempMoy: data.tempMoy, membership: data.membership, type: data.type, diameter: data.diameter)
        return cell
    }
}

extension SolarSystemViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = solarSystem[indexPath.section].data[indexPath.row]
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
        let filteredPlanets = LanguageSettings.planets.filter(filterClosure)
        let filteredMoons = LanguageSettings.moons.filter(filterClosure)
        let filteredStars = LanguageSettings.stars.filter(filterClosure)
        let filteredDwarfPlanets = LanguageSettings.dwarfPlanets.filter(filterClosure)
        
        solarSystem = [
            (category: LanguageSettings.categories[0], data: filteredStars),
            (category: LanguageSettings.categories[1], data: filteredPlanets),
            (category: LanguageSettings.categories[2], data: filteredDwarfPlanets),
            (category: LanguageSettings.categories[3], data: filteredMoons)
        ]
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

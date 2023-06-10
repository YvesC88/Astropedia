//
//  ViewController.swift
//  Planets
//
//  Created by Yves Charpentier on 16/01/2023.
//

import UIKit


final class SolarSystemViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak private var tableView: UITableView!
    
    var language = LanguageSettings(language: BundleLanguage())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchController()
        loadData()
    }
    
    private final func setupSearchController() {
        navigationItem.searchController = SolarSystemViewController.searchController
        SolarSystemViewController.searchController.searchResultsUpdater = self
        SolarSystemViewController.searchController.searchBar.delegate = self
        SolarSystemViewController.searchController.searchBar.placeholder = language.placeHolder
        definesPresentationContext = true
    }
    
    private final func loadData() {
        SolarSystemViewController.service.fetchData(collectionID: language.collectionPlanet) { [weak self] planet, error in
            guard let self = self else { return }
            if let error = error {
                print("Erreur lors du chargement des planètes:", error)
            } else {
                language.planets = planet
                self.updateSolarSystem()
            }
        }
        
        SolarSystemViewController.service.fetchData(collectionID: language.collectionDwarfPlanet) { [weak self] dwarfPlanets, error in
            guard let self = self else { return }
            if let error = error {
                print("Erreur lors du chargement des planètes naines", error)
            } else {
                language.dwarfPlanets = dwarfPlanets
                self.updateSolarSystem()
            }
        }
        SolarSystemViewController.service.fetchData(collectionID: language.collectionMoon) { [weak self] moon, error in
            guard let self = self else { return }
            if let error = error {
                print("Erreur lors du chargement des lunes:", error)
            } else {
                language.moons = moon
                self.updateSolarSystem()
            }
        }
        SolarSystemViewController.service.fetchData(collectionID: language.collectionStar) { [weak self] star, error in
            guard let self = self else { return }
            if let error = error {
                print("Erreur lors du chargement des étoiles:", error)
            } else {
                language.stars = star
                self.updateSolarSystem()
            }
        }
    }
    
    func filterData() {
        if isFiltering() {
            let searchText = SolarSystemViewController.searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() ?? ""
            language.filteredPlanets = language.planets.filter { $0.name.uppercased().hasPrefix(searchText) }
            language.filteredMoons = language.moons.filter { $0.name.uppercased().hasPrefix(searchText) }
            language.filteredStars = language.stars.filter { $0.name.uppercased().hasPrefix(searchText) }
            language.filteredDwarfPlanets = language.dwarfPlanets.filter { $0.name.uppercased().hasPrefix(searchText) }
        }
    }
    
    private final func updateSolarSystem() {
        guard !language.planets.isEmpty, !language.moons.isEmpty, !language.stars.isEmpty, !language.dwarfPlanets.isEmpty else {
            return
        }
        filterData()
        SolarSystemViewController.solarSystem = [
            (category: language.categories[0], data: isFiltering() ? language.filteredStars : language.stars),
            (category: language.categories[1], data: isFiltering() ? language.filteredPlanets : language.planets),
            (category: language.categories[2], data: isFiltering() ? language.filteredDwarfPlanets : language.dwarfPlanets),
            (category: language.categories[3], data: isFiltering() ? language.filteredMoons : language.moons)
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
        return SolarSystemViewController.solarSystem.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return SolarSystemViewController.solarSystem[section].category
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SolarSystemViewController.solarSystem[section].data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SolarSystemCell", for: indexPath) as? SolarSystemTableViewCell else {
            return UITableViewCell()
        }
        let data = SolarSystemViewController.solarSystem[indexPath.section].data[indexPath.row]
        cell.configure(name: data.name, image: data.image, tempMoy: data.tempMoy, membership: data.membership, type: data.type, diameter: data.diameter)
        return cell
    }
}

extension SolarSystemViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = SolarSystemViewController.solarSystem[indexPath.section].data[indexPath.row]
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
        let filteredPlanets = language.planets.filter(filterClosure)
        let filteredMoons = language.moons.filter(filterClosure)
        let filteredStars = language.stars.filter(filterClosure)
        let filteredDwarfPlanets = language.dwarfPlanets.filter(filterClosure)
        
        SolarSystemViewController.solarSystem = [
            (category: language.categories[0], data: filteredStars),
            (category: language.categories[1], data: filteredPlanets),
            (category: language.categories[2], data: filteredDwarfPlanets),
            (category: language.categories[3], data: filteredMoons)
        ]
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

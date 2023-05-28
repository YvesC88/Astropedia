//
//  ViewController.swift
//  Planets
//
//  Created by Yves Charpentier on 16/01/2023.
//

import UIKit


class SolarSystemViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak private var tableView: UITableView!
    
    private let searchController = UISearchController()
    
    private var planets: [FirebaseData] = []
    private var moons: [FirebaseData] = []
    private var stars: [FirebaseData] = []
    private var dwarfPlanets: [FirebaseData] = []
    private var categories: [String] = ["Étoile", "Planètes", "Planètes naines", "Lunes", ]
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
        searchController.searchBar.placeholder = "Rechercher dans le Système Solaire"
        definesPresentationContext = true
    }
    
    private final func loadData() {
        let service = FirebaseDataService(wrapper: FirebaseWrapper())
        service.fetchData(collectionID: "planets") { [weak self] planet, error in
            guard let self = self else { return }
            if let error = error {
                print("Erreur lors du chargement des planètes:", error)
            } else {
                self.planets = planet
                self.updateSolarSystem()
            }
        }
        
        service.fetchData(collectionID: "dwarfPlanets") { [weak self] dwarfPlanets, error in
            guard let self = self else { return }
            if let error = error {
                print("Erreur lors du chargement des planètes naines", error)
            } else {
                self.dwarfPlanets = dwarfPlanets
                self.updateSolarSystem()
            }
        }
        
        service.fetchData(collectionID: "moons") { [weak self] moon, error in
            guard let self = self else { return }
            if let error = error {
                print("Erreur lors du chargement des lunes:", error)
            } else {
                self.moons = moon
                self.updateSolarSystem()
            }
        }
        
        service.fetchData(collectionID: "stars") { [weak self] star, error in
            guard let self = self else { return }
            if let error = error {
                print("Erre ur lors du chargement des étoiles:", error)
            } else {
                self.stars = star
                self.updateSolarSystem()
            }
        }
    }
    
    private final func updateSolarSystem() {
        guard !planets.isEmpty, !moons.isEmpty, !stars.isEmpty else {
            return
        }
        
        var filteredPlanets: [FirebaseData] = []
        var filteredMoons: [FirebaseData] = []
        var filteredStars: [FirebaseData] = []
        var filteredDwarfPlanets: [FirebaseData] = []
        
        if isFiltering() {
            let searchText = searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() ?? ""
            filteredPlanets = planets.filter { $0.name.uppercased().hasPrefix(searchText) }
            filteredMoons = moons.filter { $0.name.uppercased().hasPrefix(searchText) }
            filteredStars = stars.filter { $0.name.uppercased().hasPrefix(searchText) }
            filteredDwarfPlanets = dwarfPlanets.filter { $0.name.uppercased().hasPrefix(searchText) }
        }
        solarSystem = [
            (category: categories[0], data: isFiltering() ? filteredStars : stars),
            (category: categories[1], data: isFiltering() ? filteredPlanets : planets),
            (category: categories[2], data: isFiltering() ? filteredDwarfPlanets : dwarfPlanets),
            (category: categories[3], data: isFiltering() ? filteredMoons : moons)
        ]
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private final func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    private final func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
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
        let detailVC = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        detailVC.data = data
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension SolarSystemViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let filteredPlanets = planets.filter { $0.name.uppercased().hasPrefix(searchText.uppercased()) }
        let filteredMoons = moons.filter { $0.name.uppercased().hasPrefix(searchText.uppercased()) }
        let filteredStars = stars.filter { $0.name.uppercased().hasPrefix(searchText.uppercased()) }
        let filteredDwarfPlanets = dwarfPlanets.filter { $0.name.uppercased().hasPrefix(searchText.uppercased()) }
        solarSystem = [
            (category: categories[0], data: filteredStars),
            (category: categories[1], data: filteredPlanets),
            (category: categories[2], data: filteredDwarfPlanets),
            (category: categories[3], data: filteredMoons)
        ]
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}


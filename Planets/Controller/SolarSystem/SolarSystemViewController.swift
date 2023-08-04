//
//  ViewController.swift
//  Planets
//
//  Created by Yves Charpentier on 16/01/2023.
//

import UIKit


final class SolarSystemViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak private var tableView: UITableView!
    
    var solarSystemCollection = SolarSystemCollection()
    let solarSystemService = SolarSystemService(wrapper: FirebaseWrapper())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchController()
        loadSolarSystem()
    }
    
    private final func setupSearchController() {
        navigationItem.searchController = SolarSystemViewController.searchController
        SolarSystemViewController.searchController.searchResultsUpdater = self
        SolarSystemViewController.searchController.searchBar.delegate = self
        SolarSystemViewController.searchController.searchBar.placeholder = "Rechercher dans le Système Solaire"
        definesPresentationContext = true
    }
    
    private final func loadSolarSystem() {
        solarSystemService.fetchSolarSystem(collectionID: "planets") { planet, error in
            if let planet = planet {
                self.solarSystemCollection.planets = planet
                self.updateSolarSystem()
            } else {
                self.presentAlert(title: "Erreur", message: String(error!))
            }
        }
        
        solarSystemService.fetchSolarSystem(collectionID: "dwarfPlanets") { dwarfPlanets, error in
            if let dwarfPlanets = dwarfPlanets {
                self.solarSystemCollection.dwarfPlanets = dwarfPlanets
                self.updateSolarSystem()
            } else {
                self.presentAlert(title: "Erreur", message: String(error!))
            }
        }
        
        solarSystemService.fetchSolarSystem(collectionID: "moons") { moon, error in
            if let moon = moon {
                self.solarSystemCollection.moons = moon
                self.updateSolarSystem()
            } else {
                self.presentAlert(title: "Erreur", message: String(error!))
            }
        }
        
        solarSystemService.fetchSolarSystem(collectionID: "stars") { star, error in
            if let star = star {
                self.solarSystemCollection.stars = star
                self.updateSolarSystem()
            } else {
                self.presentAlert(title: "Erreur", message: String(error!))
            }
        }
    }
    
    private final func updateSolarSystem() {
        if solarSystemCollection.planets.isEmpty, solarSystemCollection.moons.isEmpty, solarSystemCollection.stars.isEmpty, solarSystemCollection.dwarfPlanets.isEmpty {
            presentAlert(title: "Erreur", message: "Une erreur est survenue lors du chargement.")
        } else {
            solarSystemService.filterSolarSystem()
            solarSystemCollection.solarSystem = [
                (category: solarSystemCollection.categories[0], data: solarSystemCollection.stars),
                (category: solarSystemCollection.categories[1], data: solarSystemCollection.planets),
                (category: solarSystemCollection.categories[2], data: solarSystemCollection.dwarfPlanets),
                (category: solarSystemCollection.categories[3], data: solarSystemCollection.moons)
            ]
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

extension SolarSystemViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return solarSystemCollection.solarSystem.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return solarSystemCollection.solarSystem[section].category
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return solarSystemCollection.solarSystem[section].data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SolarSystemCell", for: indexPath) as? SolarSystemTableViewCell else {
            return UITableViewCell()
        }
        let data = solarSystemCollection.solarSystem[indexPath.section].data[indexPath.row]
        cell.configure(name: data.name, image: data.image, sat: data.sat, membership: data.membership, type: data.type, diameter: data.diameter)
        return cell
    }
}

extension SolarSystemViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let solarSystem = solarSystemCollection.solarSystem[indexPath.section].data[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let detailVC = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return }
        detailVC.solarSystem = solarSystem
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension SolarSystemViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let filterClosure: (SolarSystem) -> Bool = { data in
            return data.name.uppercased().hasPrefix(self.solarSystemCollection.searchText.uppercased())
        }
        let filteredPlanets = solarSystemCollection.planets.filter(filterClosure)
        let filteredMoons = solarSystemCollection.moons.filter(filterClosure)
        let filteredStars = solarSystemCollection.stars.filter(filterClosure)
        let filteredDwarfPlanets = solarSystemCollection.dwarfPlanets.filter(filterClosure)
        
        solarSystemCollection.solarSystem = [
            (category: solarSystemCollection.categories[0], data: filteredStars),
            (category: solarSystemCollection.categories[1], data: filteredPlanets),
            (category: solarSystemCollection.categories[2], data: filteredDwarfPlanets),
            (category: solarSystemCollection.categories[3], data: filteredMoons)
        ]
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

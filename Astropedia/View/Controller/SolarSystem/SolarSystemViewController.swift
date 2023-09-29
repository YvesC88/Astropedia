//
//  ViewController.swift
//  Astropedia
//
//  Created by Yves Charpentier on 16/01/2023.
//

import UIKit
import Combine

final class SolarSystemViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak private var tableView: UITableView!
    
    private let searchController = UISearchController()
    private var solarSystemViewModel = SolarSystemViewModel()
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchController()
        updateUI(data: solarSystemViewModel.$planets, tableView: tableView)
        updateUI(data: solarSystemViewModel.$stars, tableView: tableView)
        updateUI(data: solarSystemViewModel.$moons, tableView: tableView)
        updateUI(data: solarSystemViewModel.$dwarfPlanets, tableView: tableView)
    }
    
    private final func setupSearchController() {
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Rechercher dans le Système Solaire"
        definesPresentationContext = true
    }
    
    private final func updateUI<T>(data: Published<[T]>.Publisher, tableView: UITableView) {
        data
            .receive(on: DispatchQueue.main)
            .sink { _ in
                tableView.reloadData()
            }
            .store(in: &cancellables)
    }
}

extension SolarSystemViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return solarSystemViewModel.solarSystem.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return solarSystemViewModel.solarSystem[section].name
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return solarSystemViewModel.solarSystem[section].data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SolarSystemCell", for: indexPath) as? SolarSystemTableViewCell else {
            return UITableViewCell()
        }
        let data = solarSystemViewModel.solarSystem[indexPath.section].data[indexPath.row]
        cell.configure(name: data.name, image: data.image, sat: data.sat, membership: data.membership, type: data.type, diameter: data.diameter)
        return cell
    }
}

extension SolarSystemViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let solarSystem = solarSystemViewModel.solarSystem[indexPath.section].data[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let detailVC = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return }
        detailVC.celestObject = solarSystem
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension SolarSystemViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let filterClosure: (SolarSystem) -> Bool = { data in
            return data.name.uppercased().hasPrefix((searchController.searchBar.text?.uppercased())!)
        }
        let filteredPlanets = solarSystemViewModel.planets.filter(filterClosure)
        let filteredMoons = solarSystemViewModel.moons.filter(filterClosure)
        let filteredStars = solarSystemViewModel.stars.filter(filterClosure)
        let filteredDwarfPlanets = solarSystemViewModel.dwarfPlanets.filter(filterClosure)
        
        solarSystemViewModel.solarSystem = [
            SolarSystemCategory(name: solarSystemViewModel.categories[0], data: filteredStars),
            SolarSystemCategory(name: solarSystemViewModel.categories[1], data: filteredPlanets),
            SolarSystemCategory(name: solarSystemViewModel.categories[2], data: filteredDwarfPlanets),
            SolarSystemCategory(name: solarSystemViewModel.categories[3], data: filteredMoons)
            ]
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

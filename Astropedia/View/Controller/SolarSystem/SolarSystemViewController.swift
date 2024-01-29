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
    @IBOutlet weak private var solarSystemView: UIView!
    
    private let searchController = UISearchController()
    private var solarSystemViewModel = SolarSystemViewModel()
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - Background Image
        
        let backgroundView = UIImageView(image: UIImage(named: "BGSolarSystem"))
        backgroundView.contentMode = .scaleAspectFill
        backgroundView.frame = view.bounds
        tableView.backgroundView = backgroundView
        
        initSearchController()
        
        updateUI(data: solarSystemViewModel.$planets, tableView: tableView)
        updateUI(data: solarSystemViewModel.$stars, tableView: tableView)
        updateUI(data: solarSystemViewModel.$moons, tableView: tableView)
        updateUI(data: solarSystemViewModel.$dwarfPlanets, tableView: tableView)
    }
    
    private final func initSearchController() {
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.enablesReturnKeyAutomatically = false
        searchController.searchBar.returnKeyType = UIReturnKeyType.done
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.scopeButtonTitles = [ScopeButtonCategories.all, ScopeButtonCategories.stars, ScopeButtonCategories.planets, ScopeButtonCategories.dwarfPlanets, ScopeButtonCategories.moons]
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.tintColor = .white
        searchController.searchBar.searchTextField.textColor = .white
        searchController.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "Rechercher dans le Système Solaire", attributes: [.foregroundColor: UIColor.white])
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return solarSystemViewModel.solarSystem[section].data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SolarSystemCell", for: indexPath) as? SolarSystemTableViewCell else { return UITableViewCell() }
        let data = solarSystemViewModel.solarSystem[indexPath.section].data[indexPath.row]
        if let imagePlanet = CelestialObject.celestObjects[data.name] {
            cell.configure(name: data.name, image: imagePlanet ?? UIImage(), sat: data.sat, membership: data.membership, type: data.type, diameter: data.diameter)
        }
        cell.blurEffect()
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
        let searchBar = searchController.searchBar
        let scopeButton = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        let searchText = searchBar.text!
        
        filterForSearchTextAndScopeButton(searchText: searchText, scopeButton: scopeButton, searchController: searchController)
    }
    
    func filterForSearchTextAndScopeButton(searchText: String, scopeButton: String = ScopeButtonCategories.all, searchController: UISearchController) {
        let filterClosure: (SolarSystem) -> Bool = { data in
            return data.name.uppercased().hasPrefix((searchController.searchBar.text?.uppercased())!)
        }
        
        var filteredData: [SolarSystemCategory] = []
        
        if searchText.isEmpty {
            let categories = [ScopeButtonCategories.all, ScopeButtonCategories.stars, ScopeButtonCategories.planets, ScopeButtonCategories.dwarfPlanets, ScopeButtonCategories.moons]
            let allData = [solarSystemViewModel.stars, solarSystemViewModel.planets, solarSystemViewModel.dwarfPlanets, solarSystemViewModel.moons]
            
            filteredData = zip(categories, allData).map { SolarSystemCategory(name: $0, data: $1.filter(filterClosure)) }
        } else {
            let filteredPlanets = solarSystemViewModel.planets.filter(filterClosure)
            let filteredMoons = solarSystemViewModel.moons.filter(filterClosure)
            let filteredStars = solarSystemViewModel.stars.filter(filterClosure)
            let filteredDwarfPlanets = solarSystemViewModel.dwarfPlanets.filter(filterClosure)
            
            switch scopeButton {
            case ScopeButtonCategories.all:
                filteredData = [
                    SolarSystemCategory(name: ScopeButtonCategories.stars, data: filteredStars),
                    SolarSystemCategory(name: ScopeButtonCategories.planets, data: filteredPlanets),
                    SolarSystemCategory(name: ScopeButtonCategories.dwarfPlanets, data: filteredDwarfPlanets),
                    SolarSystemCategory(name: ScopeButtonCategories.moons, data: filteredMoons)
                ]
            case ScopeButtonCategories.stars:
                filteredData = [SolarSystemCategory(name: ScopeButtonCategories.stars, data: filteredStars)]
            case ScopeButtonCategories.planets:
                filteredData = [SolarSystemCategory(name: ScopeButtonCategories.planets, data: filteredPlanets)]
            case ScopeButtonCategories.dwarfPlanets:
                filteredData = [SolarSystemCategory(name: ScopeButtonCategories.dwarfPlanets, data: filteredDwarfPlanets)]
            case ScopeButtonCategories.moons:
                filteredData = [SolarSystemCategory(name: ScopeButtonCategories.moons, data: filteredMoons)]
            default:
                break
            }
        }
        solarSystemViewModel.solarSystem = filteredData
        tableView.reloadData()
    }
}

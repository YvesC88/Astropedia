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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        let titleLabel = UILabel()
        titleLabel.text = solarSystemViewModel.solarSystem[section].name
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 17)
//        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
        return headerView
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return solarSystemViewModel.solarSystem[section].data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SolarSystemCell", for: indexPath) as? SolarSystemTableViewCell else {
            return UITableViewCell()
        }
        let data = solarSystemViewModel.solarSystem[indexPath.section].data[indexPath.row]
        if let planetimage = SolarSystemViewController.celestObjects[data.name] {
            cell.configure(name: data.name, image: planetimage ?? UIImage(), sat: data.sat, membership: data.membership, type: data.type, diameter: data.diameter)
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
        tableView.reloadData()
    }
}

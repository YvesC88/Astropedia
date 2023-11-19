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
//        setupBlurEffectForTabBar()
        // MARK: - Background Image
        
//        let backgroundView = UIImageView(image: UIImage(named: "BGSolarSystem"))
//        backgroundView.contentMode = .scaleAspectFill
//        backgroundView.frame = view.bounds
//        tableView.backgroundView = backgroundView
        
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
        searchController.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "Rechercher dans le Système Solaire", attributes: [.foregroundColor: UIColor.white])
        definesPresentationContext = true
    }
    
    private func setupBlurEffectForTabBar() {
        // Créez un effet de flou avec le style souhaité
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.regular)

        // Créez une vue visuelle avec l'effet de flou
        let tabBarBlurView = UIVisualEffectView(effect: blurEffect)

        // Ajustez le masque de redimensionnement automatique de la vue visuelle
        tabBarBlurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // Obtenez la frame de la tabBar
        let tabBarFrame = self.tabBarController?.tabBar.frame

        // Ajustez la frame de la vue visuelle pour couvrir la tabBar
        tabBarBlurView.frame = tabBarFrame ?? CGRect.zero

        // Ajoutez la vue visuelle à la vue principale
        self.view.addSubview(tabBarBlurView)
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
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
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
//
//
//extension SolarSystemViewController: UIScrollViewDelegate {
//    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let currentOffset = scrollView.contentOffset.y
//        if currentOffset > lastContentOffset && currentOffset > 0 {
//            UIView.animate(withDuration: 0.5) {
//                self.tabBarController?.tabBar.alpha = 0
//            }
//        } else {
//            UIView.animate(withDuration: 0.2) {
//                self.tabBarController?.tabBar.alpha = 1
//            }
//        }
//        lastContentOffset = currentOffset
//    }
//}

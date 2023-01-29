//
//  ViewController.swift
//  Planets
//
//  Created by Yves Charpentier on 16/01/2023.
//

import UIKit

class PlanetViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var planets: [Planet] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    func loadData() {
        let service = PlanetService(wrapper: FirebaseWrapper())
        service.fetchPlanets(collectionID: "planets") { planet, error in
            for data in planet {
                self.planets.append(data)
            }
        }
    }
}

extension PlanetViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        planets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PresentPlanetCell", for: indexPath) as? PresentPlanetCell else {
            return UITableViewCell()
        }
        let planet = planets[indexPath.row]
        cell.configure(name: planet.name, image: planet.image, tempMoy: planet.tempMoy, sat: planet.sat)
        let info = UIImage(systemName: "info.circle.fill")
        cell.accessoryType = .detailButton
        cell.accessoryView = UIImageView(image: info)
        cell.accessoryView?.tintColor = UIColor.white
        return cell
    }
}

extension PlanetViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < planets.count {
            let planet = planets[indexPath.row]
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let customViewController = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
            customViewController.planet = planet
            self.navigationController?.pushViewController(customViewController, animated: true)
        }
    }
}

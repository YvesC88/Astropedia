//
//  MoonViewController.swift
//  Planets
//
//  Created by Yves Charpentier on 19/01/2023.
//

import UIKit

class MoonViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var planets: [Data] = [] {
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
        let service = DataService(wrapper: FirebaseWrapper())
        service.fetchData(collectionID: "moons") { planet, error in
            for data in planet {
                self.planets.append(data)
            }
        }
    }
}

extension MoonViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        planets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PresentMoonCell", for: indexPath) as? PresentPlanetCell else {
            return UITableViewCell()
        }
        let planet = planets[indexPath.row]
        cell.configure(name: planet.name, image: planet.image, tempMoy: planet.tempMoy, membership: planet.membership, type: planet.type, diameter: planet.diameter)
        let info = UIImage(systemName: "info.circle.fill")
        cell.accessoryType = .detailButton
        cell.accessoryView = UIImageView(image: info)
        cell.accessoryView?.tintColor = UIColor.systemBlue
        return cell
    }
}

extension MoonViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < planets.count {
            let planet = planets[indexPath.row]
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let customViewController = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
            customViewController.data = planet
            self.navigationController?.pushViewController(customViewController, animated: true)
        }
    }
}

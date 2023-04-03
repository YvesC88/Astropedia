//
//  AsteroidsViewController.swift
//  Planets
//
//  Created by Yves Charpentier on 31/03/2023.
//

import UIKit

class AsteroidsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var result: [APIAsteroid] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
    }
    
    
    private func fetchData() {
        let asteroidService = AsteroidService()
        asteroidService.getValue { result in
            guard let asteroids = result?.nearEarthObjects.values.flatMap( { $0 }) else {
                print("Échec")
                return
            }
            self.result = asteroids
            print("Fetched \(asteroids.count) asteroids")
        }
    }
}

extension AsteroidsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return result.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        guard indexPath.row < result.count else { return cell }
        let asteroid = result[indexPath.row]
        cell.textLabel?.text = asteroid.name
        return cell
    }
}

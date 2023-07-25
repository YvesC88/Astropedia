//
//  AsteroidsViewController.swift
//  Planets
//
//  Created by Yves Charpentier on 31/03/2023.
//

import UIKit

class AsteroidsViewController: UIViewController {
    
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var numberOfAsteroidLabel: UILabel!
    @IBOutlet weak private var datePicker: UIDatePicker!
    @IBOutlet weak private var sortButton: UIButton!
    
    private let asteroidService = AsteroidService()
    private let refreshControl = UIRefreshControl()
    private let spinner = UIActivityIndicatorView(style: .medium)
    
    private var result: [APIAsteroid] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingData()
        fetchData()
        setRefreshControl()
    }
    
    private final func loadingData() {
        spinner.startAnimating()
        tableView.backgroundView = spinner
    }
    
    private final func setRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    @objc private final func refreshTableView() {
        fetchData()
        datePicker.date = Date()
        refreshControl.endRefreshing()
        tableView.reloadData()
    }
    
    private final func fetchAsteroid(startDate: String, endDate: String) {
        asteroidService.getValue(startDate: startDate, endDate: endDate) { result in
            if let result = result {
                self.numberOfAsteroidLabel.text = "\(result.elementCount)"
            }
            guard let asteroids = result?.nearEarthObjects.values.flatMap({ $0 }) else {
                self.presentAlert(title: "Erreur", message: "Erreur réseau")
                return
            }
            self.result = asteroids
            self.spinner.stopAnimating()
        }
    }
    
    private final func fetchData() {
        let startDate = getFormattedDate(date: Date(), dateFormat: "yyyy-MM-dd")
        let endDate = getFormattedDate(date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!, dateFormat: "yyyy-MM-dd")
        self.fetchAsteroid(startDate: startDate, endDate: endDate)
        sortButton.isSelected = false
    }
    
    @IBAction private final func datePickerValueChanged(_ sender: UIDatePicker) {
        loadingData()
        let selectedDate = getFormattedDate(date: sender.date, dateFormat: "yyyy-MM-dd")
        let endDate = getFormattedDate(date: Calendar.current.date(byAdding: .day, value: 1, to: sender.date)!, dateFormat: "yyyy-MM-dd")
        fetchAsteroid(startDate: selectedDate, endDate: endDate)
        sortButton.isSelected = false
    }
    
    @IBAction private final func categoryChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            result.sort { ($0.toAsteroid().estimatedDiameter ?? 0) < ($1.toAsteroid().estimatedDiameter ?? 0) }
            sortButton.isSelected = false
        case 1:
            result.sort { ($0.toAsteroid().missDistance ?? 0) < ($1.toAsteroid().missDistance ?? 0) }
            sortButton.isSelected = false
        case 2:
            result.sort { ($0.toAsteroid().relativeVelocity ?? 0) < ($1.toAsteroid().relativeVelocity ?? 0) }
            sortButton.isSelected = false
        default:
            break
        }
        tableView.reloadData()
    }
    
    @IBAction func sortResult() {
        sortButton.isSelected = !sortButton.isSelected
        result = result.reversed()
    }
}

extension AsteroidsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return result.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? AsteroidTableViewCell else {
            return UITableViewCell()
        }
        guard indexPath.row < result.count else { return cell }
        let asteroid = result[indexPath.row].toAsteroid()
        cell.configure(name: asteroid.name,
                       size: asteroid.estimatedDiameter,
                       isPotentiallyHazardous: asteroid.isPotentiallyHazardous)
        let info = UIImage(systemName: "info.circle.fill")
        cell.accessoryType = .detailButton
        cell.accessoryView = UIImageView(image: info)
        cell.accessoryView?.tintColor = UIColor.systemBlue
        return cell
    }
}

extension AsteroidsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < result.count {
            let asteroid = result[indexPath.row].toAsteroid()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let customViewController = storyboard.instantiateViewController(withIdentifier: "DetailAsteroidViewController") as! DetailAsteroidViewController
            customViewController.asteroid = asteroid
            self.navigationController?.pushViewController(customViewController, animated: true)
        }
    }
}

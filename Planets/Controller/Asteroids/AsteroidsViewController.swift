//
//  AsteroidsViewController.swift
//  Planets
//
//  Created by Yves Charpentier on 31/03/2023.
//

import UIKit

class AsteroidsViewController: UIViewController {
    
    @IBOutlet weak private var asteroidTableView: UITableView!
    @IBOutlet weak private var numberOfAsteroidLabel: UILabel!
    @IBOutlet weak private var datePicker: UIDatePicker!
    @IBOutlet weak private var sortButton: UIButton!
    
    private let asteroidService = AsteroidService()
    private let refreshControl = UIRefreshControl()
    private let spinner = UIActivityIndicatorView(style: .medium)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        asteroidService.asteroidDelegate = self
        loadingSpinner()
        fetchData()
        setRefreshControl()
    }
    
    private final func loadingSpinner() {
        spinner.startAnimating()
        asteroidTableView.backgroundView = spinner
    }
    
    private final func setRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        asteroidTableView.addSubview(refreshControl)
    }
    
    @objc private final func refreshTableView() {
        fetchData()
        datePicker.date = Date()
        refreshControl.endRefreshing()
        asteroidTableView.reloadData()
    }
    
    private final func fetchData() {
        let startDate = getFormattedDate(date: Date(), dateFormat: "yyyy-MM-dd")
        let endDate = getFormattedDate(date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!, dateFormat: "yyyy-MM-dd")
        asteroidService.fetchAsteroid(startDate: startDate, endDate: endDate)
        sortButton.isSelected = false
    }
    
    @IBAction private final func datePickerValueChanged(_ sender: UIDatePicker) {
        loadingSpinner()
        let selectedDate = getFormattedDate(date: sender.date, dateFormat: "yyyy-MM-dd")
        let endDate = getFormattedDate(date: Calendar.current.date(byAdding: .day, value: 1, to: sender.date)!, dateFormat: "yyyy-MM-dd")
        asteroidService.fetchAsteroid(startDate: selectedDate, endDate: endDate)
        sortButton.isSelected = false
    }
    
    @IBAction private final func categoryChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            asteroidService.result.sort { ($0.toAsteroid().estimatedDiameter ?? 0) < ($1.toAsteroid().estimatedDiameter ?? 0) }
            sortButton.isSelected = false
        case 1:
            asteroidService.result.sort { ($0.toAsteroid().missDistance ?? 0) < ($1.toAsteroid().missDistance ?? 0) }
            sortButton.isSelected = false
        case 2:
            asteroidService.result.sort { ($0.toAsteroid().relativeVelocity ?? 0) < ($1.toAsteroid().relativeVelocity ?? 0) }
            sortButton.isSelected = false
        default:
            break
        }
        asteroidTableView.reloadData()
    }
    
    @IBAction func sortResult() {
        sortButton.isSelected = !sortButton.isSelected
        asteroidService.result = asteroidService.result.reversed()
    }
}

extension AsteroidsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return asteroidService.result.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? AsteroidTableViewCell else {
            return UITableViewCell()
        }
        guard indexPath.row < asteroidService.result.count else { return cell }
        let asteroid = asteroidService.result[indexPath.row].toAsteroid()
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
        if indexPath.row < asteroidService.result.count {
            let asteroid = asteroidService.result[indexPath.row].toAsteroid()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let customViewController = storyboard.instantiateViewController(withIdentifier: "DetailAsteroidViewController") as! DetailAsteroidViewController
            customViewController.asteroid = asteroid
            self.navigationController?.pushViewController(customViewController, animated: true)
        }
    }
}

extension AsteroidsViewController: AsteroidDelegate {
    func animatingSpinner() {
        spinner.stopAnimating()
    }
    
    func presentMessage(title: String, message: String) {
        presentAlert(title: title, message: message)
    }
    
    func reloadAsteroidTableView() {
        DispatchQueue.main.async {
            self.asteroidTableView.reloadData()
        }
    }
    
    func numberAsteroids(value: Int) {
        numberOfAsteroidLabel.text = "\(value)"
    }
}


/*
 func getValue(startDate: String, endDate: String) async throws -> ResultAsteroid {
     let url = "https://api.nasa.gov/neo/rest/v1/feed"
     let parameters = [
         "api_key": apiKey.keyNasa ?? "",
         "start_date": startDate,
         "end_date": endDate,
     ] as [String : Any]
     
     return try await AF.request(url, method: .get, parameters: parameters).serializingDecodable(ResultAsteroid.self).value
 }
 
 
 */

//
//  AsteroidsViewController.swift
//  Planets
//
//  Created by Yves Charpentier on 31/03/2023.
//

import UIKit
import Foundation

class AsteroidsViewController: UIViewController {
    
    @IBOutlet weak private var asteroidTableView: UITableView!
    @IBOutlet weak private var numberOfAsteroidLabel: UILabel!
    @IBOutlet weak private var datePicker: UIDatePicker!
    @IBOutlet weak private var sortButton: UIButton!
    
    private let asteroidService = AsteroidService()
    private let refreshControl = UIRefreshControl()
    private let spinner = UIActivityIndicatorView(style: .medium)
    
    var result: [APIAsteroid] = [] {
        didSet {
            DispatchQueue.main.async {
                self.asteroidTableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingSpinner()
        Task {
            await fetchData()
        }
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
        Task {
            await fetchData()
        }
        datePicker.date = Date()
        refreshControl.endRefreshing()
        asteroidTableView.reloadData()
    }
    
    private final func fetchData() async -> Result<[APIAsteroid], Error> {
        let startDate = getFormattedDate(date: Date(), dateFormat: "yyyy-MM-dd")
        let endDate = getFormattedDate(date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!, dateFormat: "yyyy-MM-dd")
        do {
            let asteroids = try await asteroidService.getValue(startDate: startDate, endDate: endDate).nearEarthObjects.flatMap { $0.value }
            sortButton.isSelected = false
            self.result = asteroids
            numberOfAsteroidLabel.text = "\(asteroids.count)"
            spinner.stopAnimating()
            return .success(asteroids)
        } catch ResultError.invalidUrl {
            presentAlert(title: "Erreur", message: "L'url n'est pas correcte.")
            return .failure(ResultError.invalidUrl)
        } catch ResultError.invalidResponse {
            presentAlert(title: "Erreur", message: "Aucune réponse du serveur.")
            return .failure(ResultError.invalidResponse)
        } catch ResultError.invalidResult {
            presentAlert(title: "Erreur", message: "Aucun résultat.")
            return .failure(ResultError.invalidResult)
        } catch {
            return .failure(error)
        }
    }
    
    @IBAction private final func datePickerValueChanged(_ sender: UIDatePicker) {
        Task { @MainActor in
            loadingSpinner()
            let selectedDate = getFormattedDate(date: sender.date, dateFormat: "yyyy-MM-dd")
            let endDate = getFormattedDate(date: Calendar.current.date(byAdding: .day, value: 1, to: sender.date)!, dateFormat: "yyyy-MM-dd")
            do {
                let asteroids = try await asteroidService.getValue(startDate: selectedDate, endDate: endDate).nearEarthObjects.flatMap { $0.value }
                sortButton.isSelected = false
                self.result = asteroids
                numberOfAsteroidLabel.text = "\(asteroids.count)"
                spinner.stopAnimating()
            } catch ResultError.invalidUrl {
                presentAlert(title: "Erreur", message: "L'url n'est pas correcte.")
            } catch ResultError.invalidResponse {
                presentAlert(title: "Erreur", message: "Aucune réponse du serveur.")
            } catch ResultError.invalidResult {
                presentAlert(title: "Erreur", message: "Aucun résultat.")
            }
        }
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
        asteroidTableView.reloadData()
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
        cell.configure(name: asteroid.name, size: asteroid.estimatedDiameter, isPotentiallyHazardous: asteroid.isPotentiallyHazardous)
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

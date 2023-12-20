//
//  AsteroidsViewController.swift
//  Astropedia
//
//  Created by Yves Charpentier on 31/03/2023.
//

import UIKit
import Combine

class AsteroidsViewController: UIViewController {
    
    @IBOutlet weak private var asteroidTableView: UITableView!
    @IBOutlet weak private var numberOfAsteroidLabel: UILabel!
    @IBOutlet weak private var datePicker: UIDatePicker!
    @IBOutlet weak private var sortButton: UIButton!
    
    private let asteroidsViewModel = AsteroidsViewModel()
    private var cancellables: Set<AnyCancellable> = []
    
    private let refreshControl = UIRefreshControl()
    private let spinner = UIActivityIndicatorView(style: .medium)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        
        setRefreshControl()
        
        asteroidsViewModel.$updateNumberAsteroid
            .receive(on: DispatchQueue.main)
            .sink { [weak self] number in
                self?.numberOfAsteroidLabel.text = "\(number ?? 0)"
            }
            .store(in: &cancellables)
        
        asteroidsViewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                if self?.asteroidsViewModel.isLoading == true {
                    self?.spinner.startAnimating()
                } else {
                    self?.spinner.stopAnimating()
                }
            }
            .store(in: &cancellables)
        
        asteroidsViewModel.$asteroid
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.asteroidTableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    private final func setUI() {
        spinner.hidesWhenStopped = true
        spinner.center = asteroidTableView.center
        asteroidTableView.addSubview(spinner)
    }
    
    private final func setRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        asteroidTableView.addSubview(refreshControl)
    }
    
    @objc private final func refreshTableView() {
        datePicker.date = Date()
        refreshControl.endRefreshing()
        asteroidTableView.reloadData()
    }
    
    
    @IBAction private final func datePickerValueChanged(_ sender: UIDatePicker) {
        Task {
            await asteroidsViewModel.fetchData(startDate:getFormattedDate(date: sender.date, dateFormat: "yyyy-MM-dd"), endDate: getFormattedDate(date: Calendar.current.date(byAdding: .day, value: 1, to: sender.date) ?? Date(), dateFormat: "yyyy-MM-dd"))
        }
        sortButton.transform = .identity
        sortButton.isSelected = false
    }
    
    @IBAction private final func categoryChanged(_ sender: UISegmentedControl) {
        sortButton.transform = .identity
        sortButton.isSelected = false
        switch sender.selectedSegmentIndex {
        case 0:
            asteroidsViewModel.asteroid.sort { ($0.toAsteroid().estimatedDiameter ?? 0) > ($1.toAsteroid().estimatedDiameter ?? 0) }
        case 1:
            asteroidsViewModel.asteroid.sort { ($0.toAsteroid().missDistance ?? 0) > ($1.toAsteroid().missDistance ?? 0) }
        case 2:
            asteroidsViewModel.asteroid.sort { ($0.toAsteroid().relativeVelocity ?? 0) > ($1.toAsteroid().relativeVelocity ?? 0) }
        default:
            break
        }
    }
    
    @IBAction func sortResult(_ sender: UIButton) {
        if sender.isSelected {
            sortButton.transform = .identity
            sortButton.isSelected = false
        } else {
            sortButton.transform = CGAffineTransform(scaleX: -1, y: -1)
            sortButton.isSelected = true
        }
        asteroidsViewModel.asteroid.reverse()
    }
}

extension AsteroidsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return asteroidsViewModel.asteroid.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? AsteroidTableViewCell else {
            return UITableViewCell()
        }
        guard indexPath.row < asteroidsViewModel.asteroid.count else { return cell }
        let asteroid = asteroidsViewModel.asteroid[indexPath.row].toAsteroid()
        cell.configure(name: asteroid.name, size: asteroid.estimatedDiameter, missDistance: asteroid.missDistance ?? 0, velocity: "\(asteroid.relativeVelocity ?? 0)", isPotentiallyHazardous: asteroid.isPotentiallyHazardous)
        let info = UIImage(systemName: "info.circle.fill")
        cell.accessoryType = .detailButton
        cell.accessoryView = UIImageView(image: info)
        cell.accessoryView?.tintColor = UIColor.systemBlue
        return cell
    }
}

extension AsteroidsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < asteroidsViewModel.asteroid.count {
            let asteroid = asteroidsViewModel.asteroid[indexPath.row].toAsteroid()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let customViewController = storyboard.instantiateViewController(withIdentifier: "DetailAsteroidViewController") as? DetailAsteroidViewController else { return }
            customViewController.asteroid = asteroid
            self.navigationController?.pushViewController(customViewController, animated: true)
        }
    }
}

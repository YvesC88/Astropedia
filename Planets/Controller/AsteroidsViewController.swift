//
//  AsteroidsViewController.swift
//  Planets
//
//  Created by Yves Charpentier on 31/03/2023.
//

import UIKit

class AsteroidsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var asteroidOfDay: UILabel!
    
    let asteroidService = AsteroidService()
    let datePicker = UIDatePicker()
    let refreshControl = UIRefreshControl()
    
    let datePickerViewController = UIViewController()
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
        setDatePicker()
        setRefreshControl()
    }
    
    private func loadingData() {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.startAnimating()
        tableView.backgroundView = spinner
    }
    
    private func dayDate(date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.locale = Locale(identifier: "FR-fr")
        asteroidOfDay.text = "Données de la NASA. \(result.count) astéroïdes trouvés au \(dateFormatter.string(from: date))"
    }
    
    private func setDatePicker() {
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "fr_FR")
        datePicker.minimumDate = Date()
    }
    
    private func setRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    private func fetchData() {
        let date = Date()
        let dateFormat = "yyyy-MM-dd"
        let startDate = self.getFormattedDate(date: date, dateFormat: dateFormat)
        let daysToAdd = 1
        let calendar = Calendar.current
        let newDate = calendar.date(byAdding: .day, value: daysToAdd, to: date)
        let endDate = self.getFormattedDate(date: newDate!, dateFormat: dateFormat)
        
        asteroidService.getValue(startDate: startDate, endDate: endDate) { result in
            guard let asteroids = result?.nearEarthObjects.values.flatMap( { $0 }) else {
                self.presentAlert(title: "Erreur", message: "Erreur réseau")
                return
            }
            self.result = asteroids
            self.dayDate(date: Date())
        }
    }
    
    @objc private func refreshTableView() {
        tableView.reloadData()
        refreshControl.endRefreshing()
        fetchData()
    }
    
    @IBAction func didTapDatePicker() {
        let alertController = UIAlertController(title: "Sélectionner une date", message: nil, preferredStyle: .actionSheet)
        let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 55, width: 250, height: 200))
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "fr_FR")
        alertController.view.addSubview(datePicker)
        alertController.addAction(UIAlertAction())
        alertController.addAction(UIAlertAction(title: "Valider", style: .default, handler: { (action) in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let selectedDate = dateFormatter.string(from: datePicker.date)
            let daysToAdd = 1
            let calendar = Calendar.current
            let newDate = calendar.date(byAdding: .day, value: daysToAdd, to: datePicker.date)
            let endDate = self.getFormattedDate(date: newDate!, dateFormat: "yyyy-MM-dd")
            self.asteroidService.getValue(startDate: selectedDate, endDate: endDate) { result in
                guard let asteroids = result?.nearEarthObjects.values.flatMap( { $0 }) else {
                    print("Échec")
                    return
                }
                self.result = asteroids
                self.dayDate(date: datePicker.date)
                self.loadingData()
                self.setRefreshControl()
            }
        }))
        alertController.addAction(UIAlertAction(title: "Annuler", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? PresentAsteroidCell else {
            return UITableViewCell()
        }
        guard indexPath.row < result.count else { return cell }
        let asteroid = result[indexPath.row].toAsteroid()
        cell.configure(name: asteroid.name!, size: asteroid.estimatedDiameter!,
                       isPotentiallyHazardous: asteroid.isPotentiallyHazardous!)
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

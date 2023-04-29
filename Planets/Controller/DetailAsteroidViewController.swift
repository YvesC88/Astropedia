//
//  DetailAsteroidViewController.swift
//  Planets
//
//  Created by Yves Charpentier on 05/04/2023.
//

import Foundation
import UIKit
import Charts

class DetailAsteroidViewController: UIViewController {
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var velocityLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var asteroidNameLabel: UILabel!
    @IBOutlet weak var urlButton: UIButton!
    @IBOutlet weak var closeDateLabel: UILabel!
    @IBOutlet weak var globalView: UIView!
    @IBOutlet weak var sizeView: UIView!
    @IBOutlet weak var velocityView: UIView!
    @IBOutlet weak var distanceView: UIView!
    @IBOutlet weak var statisticsView: UIView!
    @IBOutlet weak var legendView: UIView!
    @IBOutlet weak var infoView: UIView!
    
    var asteroid: Asteroid!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let gradientTitleLabel = self.getGradientLayer(bounds: asteroidNameLabel.bounds)
        asteroidNameLabel.textColor = self.gradientColor(bounds: asteroidNameLabel.bounds, gradientLayer: gradientTitleLabel)
        setData()
        self.setUIView(view: [sizeView, velocityView, distanceView, legendView, infoView])
    }
    
    func setData() {
        if let size = asteroid.estimatedDiameter,
           let velocity = asteroid.relativeVelocity,
           let distance = asteroid.missDistance,
           let asteroidName = asteroid.name,
           let closeDate = asteroid.closeApproachDate,
           let dangerous = asteroid.isPotentiallyHazardous,
           let absoluteMagnitude = asteroid.absoluteMagnitude {
            sizeLabel.text = size
            velocityLabel.text = "\(velocity)"
            distanceLabel.text = String(format: "%.1fx", distance)
            asteroidNameLabel.text = asteroidName
            closeDateLabel.text = "• Au plus proche de la Terre le \(closeDate)\n• \(dangerous)\n• Magnitude absolue : \(absoluteMagnitude)"
        } else {
            sizeLabel.text = "Pas de données."
            velocityLabel.text = "Pas de données."
            distanceLabel.text = "Pas de données."
            asteroidNameLabel.text = "Pas de données"
            closeDateLabel.text = "Pas de données"
        }
    }
    
    @IBAction func didTapUrl() {
        if asteroid.url != nil {
            UIApplication.shared.open(asteroid.url!)
        } else {
            self.presentAlert(title: "Erreur", message: "Le lien ne fonctionne pas.")
        }
    }
}
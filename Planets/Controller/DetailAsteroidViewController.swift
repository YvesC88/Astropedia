//
//  DetailAsteroidViewController.swift
//  Planets
//
//  Created by Yves Charpentier on 05/04/2023.
//

import Foundation
import UIKit

class DetailAsteroidViewController: UIViewController {
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var velocityLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var asteroidNameLabel: UILabel!
    @IBOutlet weak var urlButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var closeLabel: UILabel!
    @IBOutlet weak var dangerousLabel: UILabel!
    @IBOutlet weak var absoluteMagnitudeLabel: UILabel!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var legendView: UIView!
    
    var asteroid: Asteroid!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        let gradientTitleLabel = self.getGradientLayer(bounds: asteroidNameLabel.bounds)
        asteroidNameLabel.textColor = self.gradientColor(bounds: asteroidNameLabel.bounds, gradientLayer: gradientTitleLabel)
        setData()
        setUIView(view: [infoView, legendView])
    }
    
    func setData() {
        sizeLabel.text = String(format: "%.1f", asteroid.estimatedDiameter ?? "")
        velocityLabel.text = "\(asteroid.relativeVelocity ?? 0)"
        distanceLabel.text = String(format: "%.1fx", asteroid.missDistance ?? 0)
        asteroidNameLabel.text = asteroid.name ?? ""
        closeLabel.text = "• Au plus proche de la Terre le \(asteroid.closeApproachDate ?? "")"
        dangerousLabel.text = "• \(asteroid.isPotentiallyHazardous ?? "")"
        absoluteMagnitudeLabel.text = "• Magnitude absolue : \(asteroid.absoluteMagnitude ?? 0)"
    }
    
    @IBAction func didTapUrl() {
        if asteroid.url != nil {
            UIApplication.shared.open(asteroid.url!)
        } else {
            self.presentAlert(title: "Erreur", message: "Le lien ne fonctionne pas.")
        }
    }
}

extension DetailAsteroidViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let titleLabelMaxY = asteroidNameLabel.frame.maxY
        let contentOffsetY = scrollView.contentOffset.y
        let frame = scrollView.convert(asteroidNameLabel.frame, to: view)
        guard titleLabelMaxY < contentOffsetY || frame.origin.y < view.safeAreaInsets.bottom else {
            asteroidNameLabel.text = asteroid.name
            navigationItem.title = nil
            return
        }
        navigationItem.title = asteroid.name
    }
}

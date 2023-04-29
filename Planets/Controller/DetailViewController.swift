//
//  DetailViewController.swift
//  Planets
//
//  Created by Yves Charpentier on 17/01/2023.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet weak var objectImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statisticsTextView: UITextView!
    @IBOutlet weak var objectView: UIView!
    @IBOutlet weak var sourceLabel: UILabel!
    
    var data: FirebaseData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = data.name
        setUI()
        setData()
    }
    
    private func setData() {
        if let url = URL(string: data.image) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let imageData = data else { return }
                DispatchQueue.main.async {
                    self.objectImageView.image = UIImage(data: imageData)
                }
            }.resume()
        }
        titleLabel.text = "Informations"
        var statisticLine: String = ""
        for statistic in data.statistics {
            statisticLine += "• \(statistic)\n\n"
        }
        statisticsTextView.text = statisticLine
        sourceLabel.text = data.source
    }
    
    private func setUI() {
        objectView.layer.cornerRadius = 50
        objectView.clipsToBounds = true
        objectView.layer.borderWidth = 2
        objectView.layer.borderColor = UIColor.white.cgColor
        objectView.layer.backgroundColor = UIColor.black.cgColor
        statisticsTextView.layer.cornerRadius = 20
        titleLabel.layer.masksToBounds = true
        titleLabel.layer.cornerRadius = 25
        let gradientTitleLabel = self.getGradientLayer(bounds: titleLabel.bounds)
        titleLabel.textColor = self.gradientColor(bounds: titleLabel.bounds, gradientLayer: gradientTitleLabel)
    }
}

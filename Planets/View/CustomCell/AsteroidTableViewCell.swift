//
//  PresentAsteroidCell.swift
//  Planets
//
//  Created by Yves Charpentier on 03/04/2023.
//

import UIKit

class AsteroidTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var sizeImageView: UIImageView!
    @IBOutlet weak var missDistanceLabel: UILabel!
    @IBOutlet weak var missDistanceImageView: UIImageView!
    @IBOutlet weak var velocityLabel: UILabel!
    @IBOutlet weak var velocityImageView: UIImageView!
    @IBOutlet weak var isPotentiallyHazardousLabel: UILabel!
    
    var selectedIndex: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(name: String?, size: Double?, missDistance: Double, velocity: String, isPotentiallyHazardous: String?) {
        if selectedIndex == 0 {
            sizeLabel.isHidden = false
            sizeImageView.isHidden = false
            missDistanceLabel.isHidden = true
            missDistanceImageView.isHidden = true
            velocityLabel.isHidden = true
            velocityImageView.isHidden = true
        } else if selectedIndex == 1 {
            sizeLabel.isHidden = true
            sizeImageView.isHidden = true
            missDistanceLabel.isHidden = false
            missDistanceImageView.isHidden = false
            velocityLabel.isHidden = true
            velocityImageView.isHidden = true
        } else if selectedIndex == 2 {
            sizeLabel.isHidden = true
            sizeImageView.isHidden = true
            missDistanceLabel.isHidden = true
            missDistanceImageView.isHidden = true
            velocityLabel.isHidden = false
            velocityImageView.isHidden = false
        }
        if isPotentiallyHazardous == "Potentiellement dangereux" {
            isPotentiallyHazardousLabel.textColor = UIColor.systemRed
        } else {
            isPotentiallyHazardousLabel.textColor = UIColor.systemGreen
        }
        let gradient = getGradientLayer(bounds: nameLabel.bounds)
        nameLabel.textColor = gradientColor(bounds: nameLabel.bounds, gradientLayer: gradient)
        nameLabel.text = name
        sizeLabel.text = String(format: "%.1f m", size ?? 0.0)
        missDistanceLabel.text = String(format: "%.1f× la distance Terre-Lune", missDistance)
        velocityLabel.text = "\(velocity) km/s"
        isPotentiallyHazardousLabel.text = isPotentiallyHazardous
    }
    
    func getGradientLayer(bounds: CGRect) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = bounds
        //order of gradient colors
        gradient.colors = [UIColor.orange.cgColor, UIColor.blue.cgColor, UIColor.blue.cgColor]
        // start and end points
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        return gradient
    }
    
    func gradientColor(bounds: CGRect, gradientLayer: CAGradientLayer) -> UIColor? {
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        //create UIImage by rendering gradient layer.
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        //get gradient UIcolor from gradient UIImage
        return UIColor(patternImage: image!)
    }
}

//
//  PresentAsteroidCell.swift
//  Planets
//
//  Created by Yves Charpentier on 03/04/2023.
//

import UIKit

class PresentAsteroidCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var estimatedDiameterLabel: UILabel!
    @IBOutlet weak var isPotentiallyHazardousLabel: UILabel!
    
    let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(name: String, size: String, isPotentiallyHazardous: String) {
        if isPotentiallyHazardous == "Potentiellement dangereux" {
            isPotentiallyHazardousLabel.textColor = UIColor.systemRed
        } else {
            isPotentiallyHazardousLabel.textColor = UIColor.systemGreen
        }
        let gradient = getGradientLayer(bounds: nameLabel.bounds)
        nameLabel.textColor = gradientColor(bounds: nameLabel.bounds, gradientLayer: gradient)
        nameLabel.text = name
        estimatedDiameterLabel.text = "\(size) mètres"
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

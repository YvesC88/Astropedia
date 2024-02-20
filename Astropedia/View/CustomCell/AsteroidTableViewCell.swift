//
//  PresentAsteroidCell.swift
//  Astropedia
//
//  Created by Yves Charpentier on 03/04/2023.
//

import UIKit

final class AsteroidTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var sizeImageView: UIImageView!
    @IBOutlet weak var missDistanceLabel: UILabel!
    @IBOutlet weak var missDistanceImageView: UIImageView!
    @IBOutlet weak var velocityLabel: UILabel!
    @IBOutlet weak var velocityImageView: UIImageView!
    @IBOutlet weak var isPotentiallyHazardousLabel: UILabel!
    
    // Pourquoi override si tu ne fais rien de plus que la classe parent ? To delete...
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // Idem
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // Idem que pour la solar cell
    func configure(
        name: String?,
        size: Double?,
        missDistance: Double,
        velocity: String,
        isPotentiallyHazardous: String?
    ) {
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
    
    // J'ai l'impression d'avoir deja vu ce code autre part...
    // Essaie d'eviter la duplication de code. Si besoin fait une cell Mere dans laquelle y a ce setup de fait 1 seule fois
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
    
    // Idem ici
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

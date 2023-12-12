//
//  PresentPlanetCell.swift
//  Astropedia
//
//  Created by Yves Charpentier on 16/01/2023.
//

import UIKit
//import SDWebImage

final class SolarSystemTableViewCell: UITableViewCell {
    @IBOutlet weak var objectLabel: UILabel!
    @IBOutlet weak var membershipLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var objectImageView: UIImageView!
    @IBOutlet weak var diameterLabel: UILabel!
    @IBOutlet weak var satLabel: UILabel!
    @IBOutlet weak var cellView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(name: String, image: UIImage, sat: Int, membership: String, type: String, diameter: Double) {
        objectImageView.image = image
        objectLabel.text = name
        objectLabel.frame = CGRect(x: 0, y: 0, width: 500, height: 100)
        let gradient = getGradientLayer(bounds: objectLabel.bounds, colors: [UIColor(red: 39/255, green: 55/255, blue: 74/255, alpha: 1), UIColor.orange, UIColor.white])
        objectLabel.textColor = gradientColor(bounds: objectLabel.bounds, gradientLayer: gradient)
        membershipLabel.text = membership
        diameterLabel.text = "\(diameter) km"
        typeLabel.text = type
        satLabel.isHidden = sat == 0
        if sat <= 1 {
            satLabel.text = sat == 0 ? "" : "\(sat) Lune"
        } else {
            satLabel.text = sat == 0 ? "" : "\(sat) Lunes"
        }
        
    }
    
    func blurEffect() {
        // Remove blurEffect if is already applied
        for subview in cellView.subviews {
            if subview is UIVisualEffectView {
                subview.removeFromSuperview()
            }
        }
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.layer.cornerRadius = 20
        blurEffectView.clipsToBounds = true
        blurEffectView.frame = cellView.bounds
        cellView.insertSubview(blurEffectView, at: 0)
    }
    
    func getGradientLayer(bounds: CGRect, colors: [UIColor]) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = bounds
        gradient.colors = colors.map { $0.cgColor }
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 0.0, y: 1.0)
        return gradient
    }
    
    func gradientColor(bounds: CGRect, gradientLayer: CAGradientLayer) -> UIColor? {
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return UIColor(patternImage: image!)
    }
}

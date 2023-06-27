//
//  PresentPlanetCell.swift
//  Planets
//
//  Created by Yves Charpentier on 16/01/2023.
//

import UIKit
import SDWebImage

final class SolarSystemTableViewCell: UITableViewCell {
    @IBOutlet weak var objectLabel: UILabel!
    @IBOutlet weak var membershipLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var objectImageView: UIImageView!
    @IBOutlet weak var diameterLabel: UILabel!
    @IBOutlet weak var memberTextLabel: UILabel!
    @IBOutlet weak var typeTextLabel: UILabel!
    @IBOutlet weak var diameterTextLabel: UILabel!
    @IBOutlet weak var satTextLabel: UILabel!
    @IBOutlet weak var satLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(name: String, image: String, tempMoy: String, sat: Int, membership: String, type: String, diameter: Double) {
        memberTextLabel.text = memberTextLabel.text?.uppercased()
        typeTextLabel.text = typeTextLabel.text?.uppercased()
        diameterTextLabel.text = diameterTextLabel.text?.uppercased()
        satTextLabel.text = satTextLabel.text?.uppercased()
        objectImageView.sd_setImage(with: URL(string: image))
        objectLabel.text = name
        objectLabel.frame = CGRect(x: 0, y: 0, width: 500, height: 100)
        let gradient = getGradientLayer(bounds: objectLabel.bounds)
        objectLabel.textColor = gradientColor(bounds: objectLabel.bounds, gradientLayer: gradient)
        membershipLabel.text = membership
        diameterLabel.text = "\(diameter) m"
        typeLabel.text = type
        satTextLabel.isHidden = sat == 0
        satLabel.isHidden = sat == 0
        satLabel.text = sat == 0 ? "" : "\(sat)"
    }
    
    func getGradientLayer(bounds: CGRect) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = bounds
        //order of gradient colors
        gradient.colors = [UIColor.orange.cgColor, UIColor.blue.cgColor, UIColor.blue.cgColor, UIColor.white.cgColor]
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

//
//  PresentPlanetCell.swift
//  Planets
//
//  Created by Yves Charpentier on 16/01/2023.
//

import UIKit

class PresentPlanetCell: UITableViewCell {
    @IBOutlet weak var objectLabel: UILabel!
    @IBOutlet weak var membershipLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var objectImageView: UIImageView!
    @IBOutlet weak var diameterLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configure(name: String?, image: String?, tempMoy: String?, membership: String?, type: String?, diameter: Int) {
        if let url = URL(string: image!) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let imageData = data else { return }
                DispatchQueue.main.async {
                    self.objectImageView.image = UIImage(data: imageData)
                }
            }.resume()
        }
        objectLabel.text = name
        objectLabel.frame = CGRect(x: 0, y: 0, width: 500, height: 120)
        let gradient = getGradientLayer(bounds: objectLabel.bounds)
        objectLabel.textColor = gradientColor(bounds: objectLabel.bounds, gradientLayer: gradient)
        membershipLabel.text = membership!
        diameterLabel.text = "\(diameter) km"
        typeLabel.text = type
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

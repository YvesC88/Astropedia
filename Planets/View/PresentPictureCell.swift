//
//  PresentPictureCell.swift
//  Planets
//
//  Created by Yves Charpentier on 09/05/2023.
//

import UIKit

class PresentPictureCell: UITableViewCell {
    
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        pictureImageView.layer.cornerRadius = 15
        pictureImageView.clipsToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(title: String?, image: String?) {
        titleLabel.text = title
        if let url = URL(string: image!) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let imageData = data else { return }
                DispatchQueue.main.async {
                    self.pictureImageView.image = UIImage(data: imageData)
                }
            }.resume()
        }
    }
}

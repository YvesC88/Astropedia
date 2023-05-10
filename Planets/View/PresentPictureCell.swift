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
    
    func configure(title: String, image: Data) {
        titleLabel.text = title
        pictureImageView.image = UIImage(data: image)
    }
}

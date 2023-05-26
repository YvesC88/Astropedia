//
//  PresentPictureCell.swift
//  Planets
//
//  Created by Yves Charpentier on 09/05/2023.
//

import UIKit
import SDWebImage

class PictureTableViewCell: UITableViewCell {
    
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
        pictureImageView.sd_setImage(with: URL(string: image!))
    }
}

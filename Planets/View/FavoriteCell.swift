//
//  FavoriteCell.swift
//  Planets
//
//  Created by Yves Charpentier on 08/05/2023.
//

import UIKit

class FavoriteCell: UITableViewCell {
    
    @IBOutlet weak var dayImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        dayImageView.layer.cornerRadius = 15
        dayImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(title: String, image: Data) {
        titleLabel.text = title
        dayImageView.image = UIImage(data: image)
    }
}

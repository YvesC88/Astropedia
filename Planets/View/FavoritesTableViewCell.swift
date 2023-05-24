//
//  FavoriteCell.swift
//  Planets
//
//  Created by Yves Charpentier on 08/05/2023.
//

import UIKit

class FavoritesTableViewCell: UITableViewCell {
    
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
    
    func configure(title: String?, image: Data?) {
        titleLabel.text = title
        guard let image = image, let imageObject = UIImage(data: image) else {
            dayImageView.image = nil
            return
        }
        dayImageView.image = imageObject
    }
}

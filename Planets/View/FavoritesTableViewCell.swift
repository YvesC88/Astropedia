//
//  FavoriteCell.swift
//  Planets
//
//  Created by Yves Charpentier on 08/05/2023.
//

import UIKit
import SDWebImage

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
    
    func configure(title: String?, image: String?) {
        titleLabel.text = title ?? ""
        dayImageView.sd_setImage(with: URL(string: image ?? ""))
    }
}

//
//  ArticleTableViewCell.swift
//  Planets
//
//  Created by Yves Charpentier on 17/05/2023.
//

import UIKit
import SDWebImage

class ArticleTableViewCell: UITableViewCell {
    @IBOutlet weak var articleTitleLabel: UILabel!
    @IBOutlet weak var articleSubtitleLabel: UILabel!
    @IBOutlet weak var articleImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        articleImageView.layer.cornerRadius = 15
        articleImageView.clipsToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(title: String?, subtitle: String?, image: String?) {
        articleTitleLabel.text = title ?? ""
        articleSubtitleLabel.text = subtitle ?? ""
        articleImageView.sd_setImage(with: URL(string: image ?? ""))
    }
}

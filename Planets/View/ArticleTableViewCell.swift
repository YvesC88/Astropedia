//
//  ArticleTableViewCell.swift
//  Planets
//
//  Created by Yves Charpentier on 17/05/2023.
//

import UIKit

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
        articleTitleLabel.text = title
        articleSubtitleLabel.text = subtitle
        if let url = URL(string: image!) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let imageData = data else { return }
                DispatchQueue.main.async {
                    self.articleImageView.image = UIImage(data: imageData)
                }
            }.resume()
        }
    }
    
}

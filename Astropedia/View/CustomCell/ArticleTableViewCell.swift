//
//  ArticleTableViewCell.swift
//  Astropedia
//
//  Created by Yves Charpentier on 17/05/2023.
//

import UIKit
import SDWebImage

class ArticleTableViewCell: UITableViewCell {
    @IBOutlet weak var articleTitleLabel: UILabel!
    @IBOutlet weak var articleImageView: UIImageView!
    @IBOutlet weak var favoriteButton: UIButton!
    
    private var newsViewModel = NewsViewModel()
    var article: Article?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        customImage(image: articleImageView,
                    cornerRadius: 10)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(title: String?, image: String?) {
        articleTitleLabel.text = title ?? ""
        articleImageView.sd_setImage(with: URL(string: image ?? ""))
    }
    
    func setFavoriteState(isFavorite: Bool) {
        favoriteButton.isSelected = isFavorite
    }
    
    private final func customImage(image: UIImageView, cornerRadius: CGFloat) {
        image.layer.cornerRadius = cornerRadius
    }
    
    @IBAction final func favoriteButtonTapped() {
        if newsViewModel.isFavoriteArticle(article: article!) {
            newsViewModel.unsaveArticle(article: article!)
            favoriteButton.isSelected = false
        } else {
            newsViewModel.saveArticle(article: article!)
            favoriteButton.isSelected = true
        }
    }
}

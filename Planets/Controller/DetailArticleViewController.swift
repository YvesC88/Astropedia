//
//  DetailArticleViewController.swift
//  Planets
//
//  Created by Yves Charpentier on 17/05/2023.
//

import UIKit
import SDWebImage

class DetailArticleViewController: UIViewController {
    @IBOutlet weak var articleImageView: UIImageView!
    @IBOutlet weak var articleTitleLabel: UILabel!
    @IBOutlet weak var articleTextView: UITextView!
    @IBOutlet weak var subtitleTextView: UITextView!
    @IBOutlet weak var favoriteButton: UIButton!
    
    
    var article: Article!
    let articleService = ArticleService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    func setUI() {
        if articleService.isFavoriteArticle(article: article) {
            favoriteButton.isSelected = true
        } else {
            favoriteButton.isSelected = false
        }
        articleImageView.sd_setImage(with: URL(string: article.image!))
        articleTitleLabel.text = article.title
        subtitleTextView.text = article.subtitle
        if let articleTextArray = article.articleText {
            var articleText: String = ""
            for text in articleTextArray {
                articleText += "\(text)\n \n"
            }
            articleTextView.text = articleText
        } else {
            articleTextView.text = "Chargement..."
        }
    }
    
    @IBAction func didTappedFavorite() {
        let isFavorite: Bool = articleService.isFavoriteArticle(article: article)
        guard isFavorite else {
            articleService.saveArticle(title: article.title,
                                       subtitle: article.subtitle,
                                       image: article.image,
                                       source: article.source,
                                       articleText: article.articleText,
                                       id: article.id)
            favoriteButton.isSelected = true
            showInfo(title: "Enregistré")
            return
        }
        articleService.unsaveArticle(article: article)
        showInfo(title: "Effacé")
        favoriteButton.isSelected = false
    }
}

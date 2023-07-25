//
//  DetailArticleViewController.swift
//  Planets
//
//  Created by Yves Charpentier on 17/05/2023.
//

import UIKit
import SDWebImage

final class DetailArticleViewController: UIViewController {
    @IBOutlet weak private var scrollView: UIScrollView!
    @IBOutlet weak private var articleImageView: UIImageView!
    @IBOutlet weak private var articleTitleLabel: UILabel!
    @IBOutlet weak private var articleTextView: UITextView!
    @IBOutlet weak private var subtitleTextView: UITextView!
    @IBOutlet weak private var favoriteButton: UIButton!
    
    var article: Article!
    private let articleService = ArticleService(wrapper: FirebaseWrapper())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        setUI()
    }
    
    private final func setUI() {
        if let imageURL = article.image {
            articleImageView.sd_setImage(with: URL(string: imageURL))
        }
        favoriteButton.isSelected = articleService.isFavoriteArticle(article: article)
        articleTitleLabel.text = article.title
        subtitleTextView.text = article.subtitle
        articleTextView.text = article.articleText?.joined(separator: "\n \n")
    }
    
    @IBAction private final func didTappedFavorite() {
        let isFavorite: Bool = articleService.isFavoriteArticle(article: article)
        if isFavorite {
            articleService.unsaveArticle(article: article)
            favoriteButton.isSelected = false
            showInfo(title: "Supprimé")
        } else {
            articleService.saveArticle(title: article.title,
                                       subtitle: article.subtitle,
                                       image: article.image,
                                       source: article.source,
                                       articleText: article.articleText,
                                       id: article.id)
            favoriteButton.isSelected = true
            showInfo(title: "Sauvegardé")
        }
    }
}

extension DetailArticleViewController: UIScrollViewDelegate {
    
    internal final func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        if offsetY < 0 {
            let zoomFactor = 1 + abs(offsetY) / 200
            let scaleTransform = CGAffineTransform(scaleX: zoomFactor, y: zoomFactor)
            let translationTransform = CGAffineTransform(translationX: 0, y: offsetY)
            articleImageView.transform = scaleTransform.concatenating(translationTransform)
        } else {
            articleImageView.transform = CGAffineTransform.identity
        }
    }
}

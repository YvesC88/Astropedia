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
    private let articleService = ArticleService()
    private var language = LanguageSettings(language: BundleLanguage())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        setUI()
    }
    
    private final func setUI() {
        if articleService.isFavoriteArticle(article: article) {
            favoriteButton.isSelected = true
        } else {
            favoriteButton.isSelected = false
        }
        if let imageURL = article.image {
            articleImageView.sd_setImage(with: URL(string: imageURL))
        }
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
    
    @IBAction private final func didTappedFavorite() {
        let isFavorite: Bool = articleService.isFavoriteArticle(article: article)
        let title: String
        if isFavorite {
            articleService.unsaveArticle(article: article)
            title = language.deleteTitleAlert
            favoriteButton.isSelected = false
        } else {
            articleService.saveArticle(title: article.title,
                                       subtitle: article.subtitle,
                                       image: article.image,
                                       source: article.source,
                                       articleText: article.articleText,
                                       id: article.id)
            title = language.saveTitleAlert
            favoriteButton.isSelected = true
        }
        showInfo(title: title)
    }
}

extension DetailArticleViewController: UIScrollViewDelegate {
    
    internal final func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        if offsetY < 0 {
            let zoomFactor = 1 + abs(offsetY) / 1000
            let scaleTransform = CGAffineTransform(scaleX: zoomFactor, y: zoomFactor)
            let translationTransform = CGAffineTransform(translationX: 0, y: offsetY)
            articleImageView.transform = scaleTransform.concatenating(translationTransform)
        } else {
            articleImageView.transform = CGAffineTransform.identity
        }
    }
}

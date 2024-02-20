//
//  DetailArticleViewController.swift
//  Astropedia
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
    @IBOutlet weak private var shareButton: UIButton!
    @IBOutlet weak private var dismissButton: UIButton!
    
    // Si possible eviter les implicit unwrap. En entreprise on a meme souvent notre linter qui nous l'interdit.
    // Si c'est nil ca crash. Et si ca crash l'utilisateur n'est pas content hehe. Donc si pas le choix met le en optionel et gere les cas ou tu en as besoin mais il est nil.
    var article: Article!
    private let newsViewModel = NewsViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        setUI()
    }
    
    private func setUI() {
        if let imageURL = article.image {
            articleImageView.sd_setImage(with: URL(string: imageURL))
        }
        favoriteButton.isSelected = newsViewModel.isFavoriteArticle(article: article)
        articleTitleLabel.text = article.title
        subtitleTextView.text = article.subtitle
        articleTextView.text = article.articleText?.joined(separator: "\n \n")
    }
    
    private func toggleFavoriteStatus() {
        if newsViewModel.isFavoriteArticle(article: article) {
            newsViewModel.unsaveArticle(article: article)
            favoriteButton.isSelected = false
            quickAlert(title: "Supprimé")
        } else {
            newsViewModel.saveArticle(article: article)
            favoriteButton.isSelected = true
            quickAlert(title: "Sauvegardé")
        }
    }
    
    @IBAction private func didDoubleTapToFavorite() {
        toggleFavoriteStatus()
    }
    
    @IBAction private func didTapFavoriteButton() {
        toggleFavoriteStatus()
    }
    
    @IBAction private func didTapShareButton() {
        shareItems([articleImageView.image ?? UIImage(), articleTitleLabel.text ?? "", subtitleTextView.text ?? "", articleTextView.text ?? ""])
    }
    
    // Pas besoin ta classe est deja final !
    @IBAction private func dismissDetailVC() {
        dismiss(animated: true)
    }
}

extension DetailArticleViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
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

//
//  ViewController.swift
//  Astropedia
//
//  Created by Yves Charpentier on 08/05/2023.
//

import UIKit
import WebKit

final class DetailPictureViewController: UIViewController, WKNavigationDelegate {
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var pictureImageView: UIImageView!
    @IBOutlet weak private var explanationTextView: UITextView!
    @IBOutlet weak private var copyrightLabel: UILabel!
    @IBOutlet weak private var scrollView: UIScrollView!
    @IBOutlet weak private var favoriteButton: UIButton!
    @IBOutlet weak private var sharedButton: UIButton!
    @IBOutlet weak private var videoWKWebView: WKWebView!
    
//    private let newsViewModel = NewsViewModel()
    var picture: Picture!
    private let pictureService = PictureService(wrapper: FirebaseWrapper())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    private final func setUI() {
        let isFavorite = pictureService.isFavorite(picture: picture)
        favoriteButton.isSelected = isFavorite
        titleLabel.text = picture.title
        explanationTextView.text = picture.explanation
        copyrightLabel.text = picture.copyright ?? "Pas d'auteur"
        if picture.mediaType == "image" {
            videoWKWebView.isHidden = true
            pictureImageView.sd_setImage(with: URL(string: picture.imageURL ?? ""))
            sharedButton.setTitle("Partager l'image", for: .normal)
        } else {
            sharedButton.setTitle("Partager la vidéo", for: .normal)
            pictureImageView.isHidden = true
            guard let url = URL(string: picture.videoURL ?? "") else { return }
            let request = URLRequest(url: url)
            videoWKWebView.navigationDelegate = self
            videoWKWebView.load(request)
        }
    }
    
    private final func toggleFavoriteStatus() {
        let isFavorite = pictureService.isFavorite(picture: picture)
        if isFavorite {
            pictureService.unsaveRecipe(picture: picture)
            favoriteButton.isSelected = false
            quickAlert(title: "Supprimé")
        } else {
            pictureService.savePicture(title: picture.title,
                                       videoURL: picture.videoURL,
                                       imageURL: picture.imageURL,
                                       date: picture.date,
                                       mediaType: picture.mediaType,
                                       copyright: picture.copyright,
                                       explanation: picture.explanation)
            favoriteButton.isSelected = true
            quickAlert(title: "Sauvegardé")
        }
    }
    
    private final func toShare() {
        if picture.mediaType == "image" {
            guard let image = self.pictureImageView.image else { return }
            shareItems([image])
        } else {
            guard let videoURLString = picture.videoURL, let videoURL = URL(string: videoURLString) else { return }
            shareItems([videoURL])
        }
    }
    
    @IBAction private final func didSharedImage() {
        toShare()
    }
    
    @IBAction private final func saveImage() {
        toShare()
    }
    
    @IBAction private final func doubleTapFavorite() {
        toggleFavoriteStatus()
    }
    
    @IBAction private final func didTappedFavorite() {
        toggleFavoriteStatus()
    }
    
    
    @IBAction func didTapImage(_ sender: UITapGestureRecognizer) {
        let fullScreenImageViewController = FullScreenImageViewController()
        let fullScreenTransitionManager = FullScreenTransitionManager(anchorViewTag: 1)
        fullScreenImageViewController.modalPresentationStyle = .custom
        fullScreenImageViewController.transitioningDelegate = fullScreenTransitionManager
        fullScreenImageViewController.imageView.image = pictureImageView.image
        present(fullScreenImageViewController, animated: true)
    }
}

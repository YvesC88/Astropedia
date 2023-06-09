//
//  ViewController.swift
//  Planets
//
//  Created by Yves Charpentier on 08/05/2023.
//

import UIKit
import WebKit

final class DetailPictureViewController: UIViewController, WKNavigationDelegate {
    @IBOutlet weak private var uiView: UIView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var explanationTextView: UITextView!
    @IBOutlet weak private var copyrightLabel: UILabel!
    @IBOutlet weak private var scrollView: UIScrollView!
    @IBOutlet weak private var scrollImageView: UIScrollView!
    @IBOutlet weak private var favoriteButton: UIButton!
    @IBOutlet weak private var videoWKWebView: WKWebView!
    
    var picture: Picture!
    private let pictureService = PictureService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        scrollImageView.delegate = self
        scrollView.delegate = self
        uiView.layer.cornerRadius = 15
        uiView.clipsToBounds = true
        imageView.layer.cornerRadius = 15
        imageView.clipsToBounds = true
    }
    
    private final func shareItems(_ items: [Any]) {
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    private final func setUI() {
        let isFavorite = pictureService.isFavorite(picture: picture)
        favoriteButton.isSelected = isFavorite
        titleLabel.text = picture.title
        explanationTextView.text = picture.explanation
        copyrightLabel.text = picture.copyright ?? "Pas d'auteur"
        if picture.mediaType == "image" {
            videoWKWebView.isHidden = true
            imageView.sd_setImage(with: URL(string: picture.imageURL ?? ""))
        } else {
            uiView.isHidden = true
            if let url = URL(string: picture.videoURL!) {
                let request = URLRequest(url: url)
                videoWKWebView.navigationDelegate = self
                videoWKWebView.load(request)
            }
        }
    }
    
    @IBAction private final func didSharedImage() {
        if picture.mediaType == "image" {
            guard let image = self.imageView.image else { return }
            shareItems([image])
        } else {
            guard let videoURLString = picture.videoURL, let videoURL = URL(string: videoURLString) else { return }
            shareItems([videoURL])
        }
    }
    
    @IBAction private final func didTappedFavorite() {
        let isFavorite = pictureService.isFavorite(picture: picture)
        let title: String
        if isFavorite {
            pictureService.unsaveRecipe(picture: picture)
            title = LanguageSettings.currentLanguage == "fr" ? "Effacé" : "Deleted"
            favoriteButton.isSelected = false
        } else {
            pictureService.savePicture(title: picture.title,
                                       videoURL: picture.videoURL,
                                       imageURL: picture.imageURL,
                                       mediaType: picture.mediaType,
                                       copyright: picture.copyright,
                                       explanation: picture.explanation)
            title = LanguageSettings.currentLanguage == "fr" ? "Sauvegardé" : "Saved"
            favoriteButton.isSelected = true
        }
        showInfo(title: title)
    }
}

extension DetailPictureViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

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
    @IBOutlet weak private var videoWKWebView: WKWebView!
    
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
        } else {
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
        let zoomScrollView = UIScrollView(frame: UIScreen.main.bounds)
        zoomScrollView.backgroundColor = .black
        zoomScrollView.minimumZoomScale = 1.0
        zoomScrollView.maximumZoomScale = 5.0
        zoomScrollView.delegate = self
        
        let fullScreenImageView = UIImageView(image: pictureImageView.image)
        fullScreenImageView.contentMode = .scaleAspectFit
        fullScreenImageView.frame = zoomScrollView.bounds
        
        zoomScrollView.addSubview(fullScreenImageView)
        let closeGesture = UITapGestureRecognizer(target: self, action: #selector(closeFullScreenImage))
        zoomScrollView.addGestureRecognizer(closeGesture)
        
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
        self.view.addSubview(zoomScrollView)
    }
    
    @objc func closeFullScreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
    }
}

extension DetailPictureViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        for view in scrollView.subviews {
            if view is UIImageView {
                return view
            }
        }
        return nil
    }
}

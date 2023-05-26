//
//  ViewController.swift
//  Planets
//
//  Created by Yves Charpentier on 08/05/2023.
//

import UIKit

class DetailPictureViewController: UIViewController {
    @IBOutlet weak var uiView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var explanationTextView: UITextView!
    @IBOutlet weak var copyrightLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollImageView: UIScrollView!
    @IBOutlet weak var favoriteButton: UIButton!
    
    var picture: Picture!
    let pictureService = PictureService()
    
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
    
    func setUI() {
        if pictureService.isFavorite(picture: picture) {
            favoriteButton.isSelected = true
        } else {
            favoriteButton.isSelected = false
        }
        titleLabel.text = picture.title
        explanationTextView.text = picture.explanation
        if picture.copyright != nil {
            copyrightLabel.text = picture.copyright
        } else {
            copyrightLabel.text = "Pas d'auteur"
        }
        imageView.sd_setImage(with: URL(string: picture.image!))
    }
    
    @IBAction func didSharedImage() {
        guard let image = self.imageView.image else { return }
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func didTappedFavorite() {
        let isFavorite: Bool = pictureService.isFavorite(picture: picture)
        guard isFavorite else {
            pictureService.savePicture(title: picture.title, image: picture.image, copyright: picture.copyright, explanation: picture.explanation)
            showInfo(title: "Enregistré")
            favoriteButton.isSelected = true
            return
        }
        pictureService.unsaveRecipe(picture: picture)
        showInfo(title: "Effacé")
        favoriteButton.isSelected = false
    }
}

extension DetailPictureViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
}

//
//  ViewController.swift
//  Planets
//
//  Created by Yves Charpentier on 08/05/2023.
//

import UIKit

class DetailFavoriteViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var uiView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var explanationTextView: UITextView!
    @IBOutlet weak var copyrightLabel: UILabel!
    @IBOutlet weak var definitionButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollImageView: UIScrollView!
    @IBOutlet weak var favoriteButton: UIButton!
    
    var picture: Picture!
    let pictureService = PictureService()
    private var isHD = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        scrollImageView.delegate = self
        uiView.layer.cornerRadius = 15
        uiView.clipsToBounds = true
        imageView.layer.cornerRadius = 15
        imageView.clipsToBounds = true
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func setUI() {
        titleLabel.text = picture.title
        explanationTextView.text = picture.explanation
        if picture.copyright != nil {
            copyrightLabel.text = picture.copyright
        } else {
            copyrightLabel.text = "Pas d'auteur"
        }
        guard let imageSDData = picture.imageSD else { return }
        imageView.image = UIImage(data: imageSDData)
        guard pictureService.isFavorite(picture: picture) else {
            favoriteButton.isSelected = false
            return
        }
        favoriteButton.isSelected = true
    }
    
    @IBAction func hdButtonTapped(_ sender: UIButton) {
        imageView.image = UIImage(data: isHD ? picture.imageSD! : picture.imageHD!)
        definitionButton.setTitle(isHD ? "HD" : "SD", for: .normal)
        isHD.toggle()
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
            pictureService.savePicture(title: picture.title, imageSD: picture.imageSD, imageHD: picture.imageHD, copyright: picture.copyright, explanation: picture.explanation)
            presentAlert(title: "Favoris", message: "Image sauvegardée dans les favoris.")
            favoriteButton.isSelected = true
            return
        }
        pictureService.unsaveRecipe(picture: picture)
        navigationController?.popViewController(animated: true)
        favoriteButton.isSelected = false
    }
}

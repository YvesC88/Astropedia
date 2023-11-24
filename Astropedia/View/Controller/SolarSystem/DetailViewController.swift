//
//  DetailViewController.swift
//  Astropedia
//
//  Created by Yves Charpentier on 17/01/2023.
//

import UIKit
import SDWebImage
import WebKit

final class DetailViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var objectImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var statisticsTextView: UITextView!
    
    // MARK: - Properties
    
    var celestObject: SolarSystem!
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBarButtonItem()
        configureUI()
        displayDetail()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapImage))
        objectImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // MARK: - Private Methods
    
    private func displayDetail() {
        objectImageView.image = UIImage(named: celestObject.name)
        titleLabel.text = celestObject.name
        statisticsTextView.text = celestObject.statistics.map { "• \($0)" }.joined(separator: "\n\n")
    }
    
    private func configureUI() {
        titleLabel.layer.masksToBounds = true
        titleLabel.layer.cornerRadius = 25
        let gradientTitleLabel = self.getGradientLayer(bounds: titleLabel.bounds, colors: [UIColor.black, UIColor.orange, UIColor.white, UIColor.white])
        titleLabel.textColor = self.gradientColor(bounds: titleLabel.bounds, gradientLayer: gradientTitleLabel)
    }
    
    private func setupBarButtonItem() {
        let action1 = UIAction(title: "Galerie", image: UIImage(systemName: "photo.fill.on.rectangle.fill")) { action in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let detailVC = storyboard.instantiateViewController(withIdentifier: "GalleryViewController") as? GalleryViewController else { return }
            detailVC.solarSystem = self.celestObject
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
        let action2 = UIAction(title: "Partager", image: UIImage(systemName: "square.and.arrow.up")) { action in
            guard let image = self.objectImageView.image else { return }
            self.shareItems([image])
        }
        let menu = UIMenu(children: [action1, action2])
        let menuButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), menu: menu)
        navigationItem.rightBarButtonItem = menuButton
    }
    
    @objc func didTapImage() {
        let fullScreenImageViewController = FullScreenImageViewController()
        let fullScreenTransitionManager = FullScreenTransitionManager(anchorViewTag: 1)
        fullScreenImageViewController.modalPresentationStyle = .custom
        fullScreenImageViewController.transitioningDelegate = fullScreenTransitionManager
        fullScreenImageViewController.imageView.image = objectImageView.image
        present(fullScreenImageViewController, animated: true)
    }
}

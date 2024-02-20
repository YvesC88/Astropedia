//
//  DetailViewController.swift
//  Astropedia
//
//  Created by Yves Charpentier on 17/01/2023.
//

import UIKit
import SDWebImage
import WebKit

// Le naming n'est pas bon car pas assez precis. Detail de quoi ? SolarSystemDetailsViewController ?
final class DetailViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var objectImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var statisticsTextView: UITextView!
    
    // MARK: - Properties
    
    var celestObject: SolarSystem!
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        setupBarButtonItem()
//        configureUI() // to delete !
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
        let gallery = UIAction(title: "Galerie", image: UIImage(systemName: "photo.fill.on.rectangle.fill")) { action in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let detailVC = storyboard.instantiateViewController(withIdentifier: "GalleryViewController") as? GalleryViewController else { return }
            detailVC.solarSystem = self.celestObject
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
        let share = UIAction(title: "Partager", image: UIImage(systemName: "square.and.arrow.up")) { action in
            guard let image = self.objectImageView.image else { return }
            self.shareItems([image])
        }
        let menu = UIMenu(children: [gallery, share])
        let menuButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), menu: menu)
        navigationItem.rightBarButtonItem = menuButton
    }
    
    @objc private func didTapImage() {
        let fullScreenImageViewController = FullScreenImageViewController()
        let fullScreenTransitionManager = FullScreenTransitionManager(anchorViewTag: 1)
        fullScreenImageViewController.modalPresentationStyle = .custom
        fullScreenImageViewController.transitioningDelegate = fullScreenTransitionManager
        fullScreenImageViewController.imageView.image = objectImageView.image
        present(fullScreenImageViewController, animated: true)
    }
}

extension DetailViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let titleLabelMaxY = titleLabel.frame.maxY
        let contentOffsetY = scrollView.contentOffset.y
        let frame = scrollView.convert(titleLabel.frame, to: view)
        guard titleLabelMaxY < contentOffsetY || frame.origin.y < view.safeAreaInsets.bottom else {
            titleLabel.text = celestObject.name
            navigationItem.title = nil
            return
        }
        navigationItem.title = celestObject.name
    }
}

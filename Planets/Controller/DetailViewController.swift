//
//  DetailViewController.swift
//  Planets
//
//  Created by Yves Charpentier on 17/01/2023.
//

import UIKit
import SDWebImage
import WebKit

class DetailViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var objectImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var statisticsTextView: UITextView!
    @IBOutlet private weak var sourceLabel: UILabel!
    @IBOutlet private weak var scrollImageView: UIScrollView!
    @IBOutlet private weak var containView: UIView!
    @IBOutlet private weak var globalScrollView: UIScrollView!
    
    // MARK: - Properties
    
    var solarSystem: SolarSystem!
    let solarSystemService = SolarSystemService(wrapper: FirebaseWrapper())
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollImageView.delegate = self
        globalScrollView.delegate = self
        setupBarButtonItem()
        configureUI()
        displayDetail()
    }
    
    // MARK: - Private Methods
    
    private func displayDetail() {
        objectImageView.sd_setImage(with: URL(string: solarSystem.image))
        titleLabel.text = solarSystem.name
        statisticsTextView.text = solarSystem.statistics.map { "• \($0)" }.joined(separator: "\n\n")
        sourceLabel.text = solarSystem.source
    }
    
    private func configureUI() {
        titleLabel.layer.masksToBounds = true
        titleLabel.layer.cornerRadius = 25
        let gradientTitleLabel = self.getGradientLayer(bounds: titleLabel.bounds)
        titleLabel.textColor = self.gradientColor(bounds: titleLabel.bounds, gradientLayer: gradientTitleLabel)
    }
    
    private func setupBarButtonItem() {
        let action1 = UIAction(title: "Galerie", image: UIImage(systemName: "photo.fill.on.rectangle.fill")) { action in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let detailVC = storyboard.instantiateViewController(withIdentifier: "GalleryViewController") as? GalleryViewController else { return }
            detailVC.solarSystem = self.solarSystem
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
}

extension DetailViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return objectImageView
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let titleLabelMaxY = titleLabel.frame.maxY
        let contentOffsetY = globalScrollView.contentOffset.y
        let frame = globalScrollView.convert(titleLabel.frame, to: view)
        guard titleLabelMaxY < contentOffsetY || frame.origin.y < view.safeAreaInsets.bottom else {
            titleLabel.text = solarSystem.name
            navigationItem.title = nil
            return
        }
        navigationItem.title = solarSystem.name
    }
}

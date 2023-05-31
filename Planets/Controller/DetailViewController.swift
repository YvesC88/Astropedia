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
    
    var data: FirebaseData!
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollImageView.delegate = self
        globalScrollView.delegate = self
        configureUI()
        configureData()
    }
    
    // MARK: - Private Methods
    
    private func configureData() {
        objectImageView.sd_setImage(with: URL(string: data.image))
        titleLabel.text = data.name
        statisticsTextView.text = data.statistics.map { "• \($0)" }.joined(separator: "\n\n")
        sourceLabel.text = data.source
    }
    
    private func configureUI() {
        titleLabel.layer.masksToBounds = true
        titleLabel.layer.cornerRadius = 25
        let gradientTitleLabel = self.getGradientLayer(bounds: titleLabel.bounds)
        titleLabel.textColor = self.gradientColor(bounds: titleLabel.bounds, gradientLayer: gradientTitleLabel)
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
            titleLabel.text = data.name
            navigationItem.title = nil
            return
        }
        navigationItem.title = data.name
    }
}

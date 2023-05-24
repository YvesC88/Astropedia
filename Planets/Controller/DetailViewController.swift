//
//  DetailViewController.swift
//  Planets
//
//  Created by Yves Charpentier on 17/01/2023.
//

import UIKit

class DetailViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var objectImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var statisticsTextView: UITextView!
    @IBOutlet private weak var objectView: UIView!
    @IBOutlet private weak var sourceLabel: UILabel!
    @IBOutlet private weak var scrollImageView: UIScrollView!
    @IBOutlet private weak var containView: UIView!
    @IBOutlet private weak var globalScrollView: UIScrollView!
    
    // MARK: - Properties
    
    var originalTitleLabelHeight: CGFloat = 0
    var data: FirebaseData!
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollImageView.delegate = self
        globalScrollView.delegate = self
        originalTitleLabelHeight = titleLabel.frame.height
        configureUI()
        configureData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        containView.frame.size.height = view.frame.height - (tabBarController?.tabBar.frame.height ?? 0)
    }
    
    // MARK: - Private Methods
    
    private func configureData() {
        if let url = URL(string: data.image) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let imageData = data else { return }
                DispatchQueue.main.async {
                    self.objectImageView.image = UIImage(data: imageData)
                }
            }.resume()
        }
        titleLabel.text = data.name
        statisticsTextView.text = data.statistics.map { "• \($0)\n\n" }.joined()
        sourceLabel.text = data.source
    }
    
    private func configureUI() {
        objectView.layer.cornerRadius = 50
        objectView.clipsToBounds = true
        objectView.layer.backgroundColor = UIColor.black.cgColor
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
        let titleLabelMinY = titleLabel.frame.minY
        let contentOffsetY = globalScrollView.contentOffset.y
        let frame = globalScrollView.convert(titleLabel.frame, to: view)
        guard titleLabelMinY < contentOffsetY || frame.origin.y < view.safeAreaInsets.bottom else {
            titleLabel.text = data.name
            navigationItem.title = nil
            return
        }
        navigationItem.title = data.name
    }
}

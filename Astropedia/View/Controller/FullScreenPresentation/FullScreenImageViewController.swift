//
//  FullScreenImageViewController.swift
//  Astropedia
//
//  Created by Yves Charpentier on 24/11/2023.
//

import UIKit
import TinyConstraints

class FullScreenImageViewController: UIViewController {
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bouncesZoom = true
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var wrapperView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.setHugging(.defaultHigh, for: .horizontal)
        imageView.setCompressionResistance(.defaultHigh, for: .horizontal)
        return imageView
    }()
    
    private lazy var imageViewLandscapeConstraint = imageView.heightToSuperview(isActive: false, usingSafeArea: true)
    private lazy var imageViewPortraitConstraint = imageView.widthToSuperview(isActive: false, usingSafeArea: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureBehaviour()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        scrollView.setContentOffset(scrollView.contentOffset, animated: false)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        traitCollectionChanged(from: previousTraitCollection)
    }
    
    private func configureUI() {
        view.backgroundColor = .clear
        imageView.frame = scrollView.bounds
        
        view.addSubview(scrollView)
        
        scrollView.addSubview(wrapperView)
        wrapperView.addSubview(imageView)
        
        scrollView.edgesToSuperview()
        
        // The wrapper view will fill up the scroll view, and act as a target for pinch and pan event
        wrapperView.edges(to: scrollView.contentLayoutGuide)
        wrapperView.width(to: scrollView.safeAreaLayoutGuide)
        wrapperView.height(to: scrollView.safeAreaLayoutGuide)
        
        imageView.centerInSuperview()
        
        // Constraint UIImageView to fit the aspect ratio of the containing image
        let aspectRatio = imageView.intrinsicContentSize.height / imageView.intrinsicContentSize.width
        imageView.heightToWidth(of: imageView, multiplier: aspectRatio)
    }
    
    private func configureBehaviour() {
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 4.0
        
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(zoomMaxMin))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapGestureRecognizer)
    }
    
    private func traitCollectionChanged(from previousTraitCollection: UITraitCollection?) {
        if traitCollection.horizontalSizeClass != .compact {
            // Ladscape
            imageViewPortraitConstraint.isActive = false
            imageViewLandscapeConstraint.isActive = true
        } else {
            // Portrait
            imageViewLandscapeConstraint.isActive = false
            imageViewPortraitConstraint.isActive = true
        }
    }
    
    @objc private func zoomMaxMin(_ sender: UITapGestureRecognizer) {
        if scrollView.zoomScale == 1 {
            scrollView.setZoomScale(2, animated: true)
        } else {
            scrollView.setZoomScale(1, animated: true)
        }
    }
}

// MARK: UIScrollViewDelegate

extension FullScreenImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        // Make sure the zoomed image stays centred
        let currentContentSize = scrollView.contentSize
        let originalContentSize = wrapperView.bounds.size
        let offsetX = max((originalContentSize.width - currentContentSize.width) * 0.5, 0)
        let offsetY = max((originalContentSize.height - currentContentSize.height) * 0.5, 0)
        imageView.center = CGPoint(x: currentContentSize.width * 0.5 + offsetX,
                                   y: currentContentSize.height * 0.5 + offsetY)
    }
}

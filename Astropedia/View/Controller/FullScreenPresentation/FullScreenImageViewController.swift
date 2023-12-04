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
        return imageView
    }()
    
    private lazy var imageViewConstraint = imageView.widthToSuperview(isActive: false, usingSafeArea: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
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
        
        wrapperView.edges(to: scrollView.contentLayoutGuide)
        wrapperView.width(to: scrollView.safeAreaLayoutGuide)
        wrapperView.height(to: scrollView.safeAreaLayoutGuide)
        
        imageView.centerInSuperview()
        
        let aspectRatio = imageView.intrinsicContentSize.height / imageView.intrinsicContentSize.width
        imageView.heightToWidth(of: imageView, multiplier: aspectRatio)
    }
    
    private func configureBehaviour() {
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
        
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(zoomMaxMin))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapGestureRecognizer)
    }
    
    private func traitCollectionChanged(from previousTraitCollection: UITraitCollection?) {
        imageViewConstraint.isActive = true
    }
    
    @objc private func zoomMaxMin(_ sender: UITapGestureRecognizer) {
        let targetZoomScale: CGFloat = (scrollView.zoomScale == 1) ? 3 : 1
        scrollView.setZoomScale(targetZoomScale, animated: true)
    }
}

// MARK: UIScrollViewDelegate

extension FullScreenImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let currentContentSize = scrollView.contentSize
        let originalContentSize = wrapperView.bounds.size
        let offsetX = max((originalContentSize.width - currentContentSize.width) * 0.5, 0)
        let offsetY = max((originalContentSize.height - currentContentSize.height) * 0.5, 0)
        imageView.center = CGPoint(x: currentContentSize.width * 0.5 + offsetX,
                                   y: currentContentSize.height * 0.5 + offsetY)
    }
}

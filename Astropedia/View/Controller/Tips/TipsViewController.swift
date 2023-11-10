//
//  TipsViewController.swift
//  Astropedia
//
//  Created by Yves Charpentier on 11/10/2023.
//

import UIKit

class TipsViewController: UIViewController {
    
    @IBOutlet private weak var tipsView: UIView!
    @IBOutlet private weak var tips2View: UIView!
    @IBOutlet private weak var tips3View: UIView!
    @IBOutlet private weak var globalView: UIView!
    
    lazy var gradient: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.type = .axial
        gradient.colors = [
            UIColor(red: 39/255, green: 55/255, blue: 74/255, alpha: 1).cgColor,
            UIColor.gray.cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)
        return gradient
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gradient.frame = view.bounds
        view.layer.insertSublayer(gradient, at: 0)
        applyBlurEffect(to: tipsView, withCornerRadius: 20)
        applyBlurEffect(to: tips2View, withCornerRadius: 20)
        applyBlurEffect(to: tips3View, withCornerRadius: 20)
    }
}

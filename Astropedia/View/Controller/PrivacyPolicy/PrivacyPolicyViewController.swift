//
//  PrivacyPolicyViewController.swift
//  Astropedia
//
//  Created by Yves Charpentier on 26/05/2023.
//

import UIKit

// Tous tes ViewController devraient dans 99% des cas etre final
final class PrivacyPolicyViewController: UIViewController {

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dateEffectLabel: UILabel!
    @IBOutlet private weak var privacyPolicyTextView: UITextView!
    
    let privacyPolicyService = PrivacyPolicyService(wrapper: FirebaseWrapper())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        privacyPolicyService.privacyPolicyDelegate = self
        privacyPolicyService.loadPrivacyPolicy()
    }
    
    @IBAction func closePrivacyPolicyVC() {
        dismiss(animated: true)
    }
}

extension PrivacyPolicyViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let titleLabelMinY = titleLabel.frame.minY
        let contentOffsetY = scrollView.contentOffset.y
        let frame = scrollView.convert(titleLabel.frame, to: view)
        guard titleLabelMinY < contentOffsetY || frame.origin.y < view.safeAreaInsets.bottom else {
            titleLabel.text = privacyPolicyService.privacyPolicy.first?.title
            navigationItem.title = nil
            return
        }
        navigationItem.title = privacyPolicyService.privacyPolicy.first?.title
    }
}

extension PrivacyPolicyViewController: PrivacyPolicyDelegate {
    
    func displayPrivacyPolicy(title: String, date: String, text: String) {
        titleLabel.text = title
        dateEffectLabel.text = date
        privacyPolicyTextView.text = text
    }
}

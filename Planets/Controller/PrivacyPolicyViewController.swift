//
//  PrivacyPolicyViewController.swift
//  Planets
//
//  Created by Yves Charpentier on 26/05/2023.
//

import UIKit

class PrivacyPolicyViewController: UIViewController {
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dateEffectLabel: UILabel!
    @IBOutlet private weak var privacyPolicyTextView: UITextView!
    
    private var privacyPolicy: [PrivacyPolicy] = []
    let privacyPolicyService = PrivacyPolicyService(wrapper: FirebaseWrapper())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        loadPrivacyPolicy()
    }
    
    private final func loadPrivacyPolicy() {
        privacyPolicyService.fetchPrivacyPolicy(collectionID: "privacyPolicy") { privacyPolicy, error in
            for data in privacyPolicy {
                self.privacyPolicy = privacyPolicy
                self.titleLabel.text = data.title
                self.dateEffectLabel.text = data.date
                let privacyPolicyText = data.privacyPolicyText.joined(separator: "\n\n")
                self.privacyPolicyTextView.text = privacyPolicyText
            }
        }
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
            titleLabel.text = privacyPolicy.first?.title
            navigationItem.title = nil
            return
        }
        navigationItem.title = privacyPolicy.first?.title
    }
}

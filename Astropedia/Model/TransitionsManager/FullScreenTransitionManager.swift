//
//  FullScreenTransitionManager.swift
//  Astropedia
//
//  Created by Yves Charpentier on 24/11/2023.
//

import Foundation
import UIKit

final class FullScreenTransitionManager: NSObject, UIViewControllerTransitioningDelegate {
    private let anchorViewTag: Int
    private weak var anchorView: UIView?
    
    init(anchorViewTag: Int) {
        self.anchorViewTag = anchorViewTag
    }
    
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        anchorView = (presenting ?? source).view.viewWithTag(anchorViewTag)
        return FullScreenPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        FullScreenAnimationController()
    }
}

// MARK: UIViewControllerAnimatedTransitioning

final class FullScreenAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.6
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toView = transitionContext.view(forKey: .to) else {
            transitionContext.completeTransition(false)
            return
        }
        
        let containerView = transitionContext.containerView
        let containerViewCenter = CGPoint(x: containerView.bounds.midX, y: containerView.bounds.midY)
        toView.center = containerViewCenter
        toView.transform = CGAffineTransform(scaleX: 0.001, y: 00.01)
        containerView.insertSubview(toView, at: 1)
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.1, options: .curveEaseInOut, animations: {
            toView.transform = .identity
        }, completion: { (finished) in
            transitionContext.completeTransition(finished)
        })
    }
}

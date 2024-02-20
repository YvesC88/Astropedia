//
//  TransitionManager.swift
//  Astropedia
//
//  Created by Yves Charpentier on 08/11/2023.
//

import UIKit

final class TransitionManager: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toView = transitionContext.view(forKey: .to) else {
            transitionContext.completeTransition(false)
            return
        }
        
        let containerView = transitionContext.containerView
        let containerViewCenter = CGPoint(x: containerView.bounds.midX, y: containerView.bounds.midY)
        toView.center = containerViewCenter
        toView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        containerView.addSubview(toView)
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.3, options: .curveEaseInOut, animations: {
            toView.transform = .identity
        }, completion: { (finished) in
            transitionContext.completeTransition(finished)
        })
    }
}

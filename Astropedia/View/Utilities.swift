//
//  Utilities.swift
//  Astropedia
//
//  Created by Yves Charpentier on 21/01/2023.
//

import UIKit

extension UIViewController {
    
    static let dateFormat = "yyyy-MM-dd"
    
    func getGradientLayer(bounds: CGRect) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = bounds
        //order of gradient colors
        gradient.colors = [UIColor.orange.cgColor, UIColor.purple.cgColor]
        // start and end points
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        return gradient
    }
    
    func gradientColor(bounds: CGRect, gradientLayer: CAGradientLayer) -> UIColor? {
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return UIColor() }
        UIGraphicsEndImageContext()
        return UIColor(patternImage: image)
    }
    
    func getFormattedDate(date: Date, dateFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: date)
    }
    
    func presentAlert(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
    func quickAlert(title: String) {
        let alertController = UIAlertController(title: title, message: "", preferredStyle: .alert)
        present(alertController, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            alertController.dismiss(animated: true, completion: nil)
        }
    }
    
    func showAlertDeleteFavorite(title: String, message: String, cancel: String, delete: String, confirm: String, isEmpty: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: cancel, style: .default)
        alertVC.addAction(confirmAction)
        let cancelAction = UIAlertAction(title: delete, style: .destructive) { action in
            if CoreDataStack.share.hasData() {
                // element in CoreData
                do {
                    try CoreDataStack.share.deleteAllData()
                    self.quickAlert(title: confirm)
                } catch {
                    self.presentAlert(title: "Error", message: "Une erreur est survenue lors de la suppression des favoris. Veuillez réessayer.")
                }
            } else {
                // nothing element in CoreData
                self.presentAlert(title: "Impossible", message: isEmpty)
            }
        }
        alertVC.addAction(cancelAction)
        alertVC.preferredAction = confirmAction
        present(alertVC, animated: true, completion: nil)
    }
    
    func setUIButton(button: [UIButton]) {
        let buttons = button
        for button in buttons {
            button.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.5).cgColor
            button.layer.borderWidth = 2
            button.layer.cornerRadius = 20
        }
    }
    
    func colorSelectedButton(button: UIButton) {
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.layer.borderWidth = 2
    }
    
    func correctColorButton(button: UIButton) {
        button.layer.borderColor = UIColor.systemGreen.cgColor
        button.layer.borderWidth = 2
    }
    
    func incorrectColorButton(button: UIButton) {
        button.layer.borderColor = UIColor.systemRed.cgColor
        button.layer.borderWidth = 2
    }
    
    func resetSelectedButton(buttons: [UIButton]) {
        for button in buttons {
            button.layer.borderColor = UIColor.clear.cgColor
            button.layer.borderWidth = 0
        }
    }
    
    func setUIView(view: [UIView]) {
        let views = view
        for view in views {
            view.layer.cornerRadius = 15
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOpacity = 0.2
            view.center = self.view.center
            view.layer.shadowOffset = CGSize.zero
            view.layer.shadowRadius = 15
        }
    }
    
    final func shareItems(_ items: [Any]) {
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
}

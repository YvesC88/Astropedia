//
//  Utilities.swift
//  Planets
//
//  Created by Yves Charpentier on 21/01/2023.
//

import UIKit

extension UIViewController {
    
    static let service = FirebaseDataService(wrapper: FirebaseWrapper())
    static let searchController = UISearchController()
    
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
        //create UIImage by rendering gradient layer.
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        //get gradient UIcolor from gradient UIImage
        return UIColor(patternImage: image!)
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
    
    func showInfo(title: String) {
        let alertController = UIAlertController(title: title, message: "", preferredStyle: .alert)
        present(alertController, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            alertController.dismiss(animated: true, completion: nil)
        }
    }
    
    func languageDidChange(language: String) {
        UserDefaults.standard.set([language], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }
    
    func showAlertDeleteFavorite(forLanguage language: String) {
        let title: String
        let confirmDeleteTitle: String
        let message: String
        let cancelTitle: String
        let deleteTitle: String
        let isEmptyMessage: String
        
        if language == "fr" {
            title = "Suppression des favoris"
            confirmDeleteTitle = "Supprimé"
            message = "Êtes-vous sûr de vouloir supprimer vos favoris ?"
            cancelTitle = "Annuler"
            deleteTitle = "Effacer"
            isEmptyMessage = "Votre liste de favoris est vide. Cliquez sur ♥️ pour en ajouter !"
        } else {
            title = "Delete favorite"
            confirmDeleteTitle = "Deleted"
            message = "Are you sure you want to delete your favorites?"
            cancelTitle = "Cancel"
            deleteTitle = "Delete"
            isEmptyMessage = "Your favorites list is empty. Click on ♥️ to add more!"
        }
        
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: cancelTitle, style: .default)
        alertVC.addAction(confirmAction)
        
        let cancelAction = UIAlertAction(title: deleteTitle, style: .destructive) { action in
            if CoreDataStack.share.hasData() {
                // element in CoreData
                do {
                    try CoreDataStack.share.deleteAllData()
                    self.showInfo(title: confirmDeleteTitle)
                } catch {
                    self.presentAlert(title: "Error", message: "Une erreur est survenue lors de la suppression des favoris. Veuillez réessayer.")
                }
            } else {
                // nothing element in CoreData
                self.presentAlert(title: "Impossible", message: isEmptyMessage)
            }
        }
        alertVC.addAction(cancelAction)
        
        alertVC.preferredAction = confirmAction
        present(alertVC, animated: true, completion: nil)
    }
    
    func showLanguageChangeAlert(forLanguage language: String) {
        let title: String
        let message: String
        let cancelTitle: String
        let confirmTitle: String
        let infoTitle: String
        if language == "fr" {
            title = "Change language"
            message = "Would you like to use French like language?"
            cancelTitle = "Cancel"
            confirmTitle = "OK"
            infoTitle = "Restart application"
        } else {
            title = "Changer la langue"
            message = "Voulez-vous utiliser l'Anglais comme langue ?"
            cancelTitle = "Annuler"
            confirmTitle = "OK"
            infoTitle = "Relancer l'application"
        }
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: cancelTitle, style: .default)
        alertVC.addAction(cancelAction)
        let confirmAction = UIAlertAction(title: confirmTitle, style: .destructive) { action in
            self.languageDidChange(language: language)
            self.showInfo(title: infoTitle)
        }
        alertVC.addAction(confirmAction)
        alertVC.preferredAction = cancelAction
        present(alertVC, animated: true, completion: nil)
    }
    
    func setUIButton(button: [UIButton]) {
        let buttons = button
        for button in buttons {
            button.layer.borderColor = UIColor.systemPurple.withAlphaComponent(0.5).cgColor
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
    
    func updateColorAfterCheck(button: UIButton, color: CGColor) {
        button.layer.borderColor = color
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

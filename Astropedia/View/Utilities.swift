//
//  Utilities.swift
//  Astropedia
//
//  Created by Yves Charpentier on 21/01/2023.
//

import UIKit

// Si possible a eviter ca ressemble a un fourre-tout :D
// Imagine si t'as 4 devs qui bossent sur le projet avec toi rien qu'1 an. Je pense qu'on arrivera au 10000 lignes de codes dans ce fichier :D
// Y a plein de chose qui n'ont rien a voir avec ton ViewController specialement. Comme le date format ou la core data stack
// Si toutes choses sont utilisees dans TOUS tes VC alors ok mais je suis sur que c'est pas le cas ;)
// Decompose encore une fois. Plusieurs fichier, differentes extensions sur d'autres types par ex.
extension UIViewController {
    
    // Ca n'a rien a faire ici selon moi
    static let dateFormat = "yyyy-MM-dd"
    // Idem, tous tes ViewController doivent avoir une copie de Core Data ?
    // pourquoi aussi ne pas utiliser la property shared au lieu de le creer a chaque fois ?
    static let coreDataStack = CoreDataStack()
    
    func getGradientLayer(bounds: CGRect, colors: [UIColor]) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = bounds
        //order of gradient colors
        gradient.colors = colors.map { $0.cgColor }
        gradient.startPoint = CGPoint(x: 0, y: 1)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        return gradient
    }
    
    // toPushVC ? Ca veut dire quoi ? Pb de naming au niveau de l'anglais ici
    // func pushViewController(for identifier: String) ?
    func toPushVC(with identifier: String) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        self.navigationController?.pushViewController(storyboard.instantiateViewController(withIdentifier: identifier), animated: true)
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
    
    // Cette methode n'a pas de sens ici. Est-ce que TOUS tes viewControllers en ont besoin ? Si oui ok mais j'en doute ?
    func showAlertDeleteFavorite(title: String, message: String, cancel: String, delete: String, confirm: String, isEmpty: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: cancel, style: .default)
        alertVC.addAction(confirmAction)
        let cancelAction = UIAlertAction(title: delete, style: .destructive) { action in
            if UIViewController.coreDataStack.hasData() {
                // element in CoreData
                do {
                    try UIViewController.coreDataStack.deleteAllData()
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
        // Personne nous dit qu'on est sur le main thread ici
        // DispatchQueue.main.async { ... }
        present(alertVC, animated: true, completion: nil)
    }
    
    func setUIButton(button: [UIButton], borderColor: UIColor) {
        let buttons = button
        for button in buttons {
            button.layer.cornerRadius = 15
            button.layer.borderColor = borderColor.cgColor
            button.layer.borderWidth = 5
        }
    }
    
    func resetSelectedButton(buttons: [UIButton]) {
        for button in buttons {
            button.layer.borderColor = UIColor.clear.cgColor
            button.layer.borderWidth = 0
        }
    }
    
    // Le naming ne nous dit rien ici, il est trop generic. Le naming des param n'est pas bon non plus tu te repetes et il manque le pluriel car on a un array de view: setupViews(_ views: [UIView])
    // Avec un naming qui nous aider a comprendre ce qui est fait ca peut donner :
    // func setupSubviewsLayer(_ views: [UIView])
    // Et encore pourquoi faire ce setup pour plusieurs views ? On ne voit que celle qui est au dessus de toute. Et la premiere clipsToBounds celle qui sont derriere
    // Je ne vois pas de use case ou tu aurais besoin de faire ca
    func setUIView(view: [UIView]) {
        view.forEach { view in
            view.layer.cornerRadius = 15
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOpacity = 0.2
            view.center = self.view.center // Pas de constraints avec autolayout ?
            view.layer.shadowOffset = CGSize.zero
            view.layer.shadowRadius = 15
        }
    }
    
    func applyBlurEffect(to view: UIView, blurStyle: UIBlurEffect.Style, blurAlpha: CGFloat, withCornerRadius cornerRadius: CGFloat) {
        let blurEffect = UIBlurEffect(style: blurStyle)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        view.layer.cornerRadius = cornerRadius
        view.clipsToBounds = true
        blurEffectView.clipsToBounds = true
        blurEffectView.frame = view.bounds
        blurEffectView.alpha = blurAlpha
        view.insertSubview(blurEffectView, at: 0)
    }

    func shareItems(_ items: [Any]) {
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        // Personne nous dit qu'on est sur le main thread ici
        // DispatchQueue.main.async { ... }
        self.present(activityViewController, animated: true, completion: nil)
    }
}

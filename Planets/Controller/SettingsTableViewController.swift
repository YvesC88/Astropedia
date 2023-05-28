//
//  SettingsTableViewController.swift
//  Planets
//
//  Created by Yves Charpentier on 25/05/2023.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet private weak var darkModeSwitch: UISwitch!
    
    let themeKey = "preferredTheme"
    let switchKey = "switchState"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let savedTheme = UserDefaults.standard.string(forKey: themeKey) {
            applyTheme(theme: savedTheme)
        }
        darkModeSwitch.isOn = UserDefaults.standard.bool(forKey: switchKey)
    }
    
    func applyTheme(theme: String) {
        UIApplication.shared.windows.forEach { window in
            if theme == "light" {
                window.overrideUserInterfaceStyle = .light
            } else {
                window.overrideUserInterfaceStyle = .dark
            }
        }
        UserDefaults.standard.set(theme, forKey: themeKey)
    }
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            applyTheme(theme: "dark")
        } else {
            applyTheme(theme: "light")
        }
        UserDefaults.standard.set(sender.isOn, forKey: switchKey)
    }
    
    @IBAction func closeSettings() {
        dismiss(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let alertVC = UIAlertController(title: "Suppression", message: "Êtes-vous sûr de vouloir supprimer vos favoris ?", preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: "Annuler", style: .default)
            alertVC.addAction(confirmAction)
            let cancelAction = UIAlertAction(title: "Effacer", style: .destructive) { action in
                if CoreDataStack.share.hasData() {
                    // element in CoreData
                    do {
                        try CoreDataStack.share.deleteAllData()
                        self.showInfo(title: "Supprimé")
                    } catch {
                        self.presentAlert(title: "Erreur", message: "Une erreur est survenue lors de la suppression des favoris. Veuillez réessayer.")
                    }
                } else {
                    // nothing element in CoreData
                    self.presentAlert(title: "Impossible", message: "Votre liste de favoris est vide. Cliquez sur le cœur pour en ajouter !")
                }
            }
            alertVC.addAction(cancelAction)
            alertVC.preferredAction = confirmAction
            present(alertVC, animated: true, completion: nil)
        }
    }
}

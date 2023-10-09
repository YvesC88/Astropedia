//
//  SettingsTableViewController.swift
//  Astropedia
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if indexPath.row == 1 {
                showAlertDeleteFavorite(title: "Suppression des favoris",
                                        message: "Êtes-vous sûr de vouloir supprimer vos favoris ?",
                                        cancel: "Annuler",
                                        delete: "Effacer",
                                        confirm: "Supprimé",
                                        isEmpty: "Votre liste de favoris est vide. Cliquez sur ♥️ pour en ajouter !")
            }
        }
        if indexPath.section == 2 {
            if indexPath.row == 1 {
                if let appUrl = URL(string: "https://apps.apple.com/fr/app/astrop%C3%A9dia/id1668668756") {
                    UIApplication.shared.open(appUrl)
                }
                
            }
            if indexPath.row == 2 {
                if let appUrl = URL(string: "https://apps.apple.com/fr/app/astrop%C3%A9dia/id1668668756") {
                    shareItems([appUrl])
                }
            }
            if indexPath.row == 3 {
                if let moreAppUrl = URL(string: "https://apps.apple.com/us/developer/yves-charpentier/id1654705165") {
                    UIApplication.shared.open(moreAppUrl)
                }
            }
        }
    }
}

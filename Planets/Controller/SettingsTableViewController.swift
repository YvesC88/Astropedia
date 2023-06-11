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
    var currentLanguage = Bundle.main.preferredLocalizations.first
    
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
            if indexPath.row == 0 {
                if currentLanguage != "fr" {
                    showLanguageChangeAlert(forLanguage: "fr")
                } else {
                    self.showInfo(title: "La langue est déjà en français.")
                }
            }

            if indexPath.row == 1 {
                if currentLanguage != "en" {
                    showLanguageChangeAlert(forLanguage: "en")
                } else {
                    self.showInfo(title: "The language is already in english.")
                }
            }
        }
        if indexPath.section == 2 {
            if indexPath.row == 1 {
                showAlertDeleteFavorite(forLanguage: currentLanguage!)
            }
        }
    }
}

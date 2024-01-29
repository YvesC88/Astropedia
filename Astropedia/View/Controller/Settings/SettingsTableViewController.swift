//
//  SettingsTableViewController.swift
//  Astropedia
//
//  Created by Yves Charpentier on 25/05/2023.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet private weak var notificationsSwitch: UISwitch!
    
    private var newsViewModel = NewsViewModel()
    
    let keyTheme = "preferredTheme"
    let keyAppearence = "switchAppearence"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notificationsSwitch.isOn = UserDefaults.standard.bool(forKey: "isAllowed")
    }
    
    @IBAction func switchNotificationChanged(_ sender: UISwitch) {
        if sender.isOn {
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                switch settings.authorizationStatus {
                case .notDetermined:
                    DispatchQueue.main.async {
                        if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(appSettings, options: [:])
                        }
                        sender.isOn = false
                    }
                case .denied:
                    DispatchQueue.main.async {
                        if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(appSettings, options: [:])
                        }
                        self.newsViewModel.scheduleDailyNotification()
                    }
                case .authorized:
                    DispatchQueue.main.async {
                        self.newsViewModel.scheduleDailyNotification()
                    }
                case .provisional, .ephemeral:
                    print("")
                @unknown default:
                    break
                }
            }
        } else {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyNotification"])
        }
        UserDefaults.standard.set(sender.isOn, forKey: "isAllowed")
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                toPushVC(with: "FavoritesViewController")
            case 1:
                showAlertDeleteFavorite(title: "Suppression des favoris",
                                        message: "Êtes-vous sûr de vouloir supprimer vos favoris ?",
                                        cancel: "Annuler",
                                        delete: "Effacer",
                                        confirm: "Supprimé",
                                        isEmpty: "Votre liste de favoris est vide. Cliquez sur ♥️ pour en ajouter !")
            default:
                break
            }
        }
        if indexPath.section == 2 {
            switch indexPath.row {
            case 0:
                toPushVC(with: "TipsViewController")
            case 1:
                if let appUrl = URL(string: "https://apps.apple.com/fr/app/astrop%C3%A9dia/id1668668756") {
                    UIApplication.shared.open(appUrl)
                }
            case 2:
                if let appUrl = URL(string: "https://apps.apple.com/fr/app/astrop%C3%A9dia/id1668668756") {
                    shareItems([appUrl])
                }
            case 3:
                if let moreAppUrl = URL(string: "https://apps.apple.com/us/developer/yves-charpentier/id1654705165") {
                    UIApplication.shared.open(moreAppUrl)
                }
            default:
                break
            }
        }
    }
}

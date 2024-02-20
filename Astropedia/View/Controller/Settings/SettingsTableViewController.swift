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
        notificationsSwitch.isOn = UserDefaults.standard.bool(forKey: "isAllowed") // A mettre dans ton ViewModel ! avec une property isNotificationSwitchOn: Bool
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
                    print("") // ? On laisse rien trainer il faut que tout soit clean le + possible :)
                @unknown default:
                    break
                }
            }
        } else {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyNotification"])
        }
        UserDefaults.standard.set(sender.isOn, forKey: "isAllowed") // ViewModel !
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Soucis de conception algo ici
        // Si ta section faut 0 ou 3 par ex, le user va taper et rien va se passer et toi t'en saura rien en prod.
        if indexPath.section == 1 {
            // Ici le switch n'a pas d'interet
            // Autant utiliser un if else
            // Le mieux aurait ete de creer une enum pour definir ces row

            enum SettingsFavoritesRow: Int {
                case favorites
                case deleteFavorites
            }

            switch indexPath.row {
            case SettingsFavoritesRow.favorites.rawValue:
                toPushVC(with: "FavoritesViewController")
            case SettingsFavoritesRow.deleteFavorites.rawValue:
                showAlertDeleteFavorite(title: "Suppression des favoris",
                                        message: "Êtes-vous sûr de vouloir supprimer vos favoris ?",
                                        cancel: "Annuler",
                                        delete: "Effacer",
                                        confirm: "Supprimé",
                                        isEmpty: "Votre liste de favoris est vide. Cliquez sur ♥️ pour en ajouter !")
            default:
                break
            }

            // On peut faire encore mieux mais c'est deja + clair

//            switch indexPath.row {
//            case 0:
//                toPushVC(with: "FavoritesViewController")
//            case 1:
//                showAlertDeleteFavorite(title: "Suppression des favoris",
//                                        message: "Êtes-vous sûr de vouloir supprimer vos favoris ?",
//                                        cancel: "Annuler",
//                                        delete: "Effacer",
//                                        confirm: "Supprimé",
//                                        isEmpty: "Votre liste de favoris est vide. Cliquez sur ♥️ pour en ajouter !")
//            default:
//                break
//            }
        }
        if indexPath.section == 2 {

            // Idem ici
            enum SettingsOthersRow: Int {
                case tips
                case app
                case share
                case more
            }

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

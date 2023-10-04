//
//  AppDelegate.swift
//  Astropedia
//
//  Created by Yves Charpentier on 16/01/2023.
//

import UIKit
import Firebase
import UserNotifications
import BackgroundTasks

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var orientationLock = UIInterfaceOrientationMask.portrait
    var window: UIWindow?
    var newsViewModel: NewsViewModel?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        newsViewModel = NewsViewModel()
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notifications are allowed")
            } else {
                print("Noticiations are not allowed")
            }
        }
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Votre code de récupération de données ici
        guard let newsViewModel = self.newsViewModel else {
            completionHandler(.failed)
            return
        }
        
        newsViewModel.fetchPictures()
        // Une fois la tâche terminée, appelez le completionHandler avec le résultat approprié.
        // Par exemple, .newData si de nouvelles données ont été récupérées.
        completionHandler(.newData)
    }

}


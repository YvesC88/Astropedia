//
//  AppDelegate.swift
//  Astropedia
//
//  Created by Yves Charpentier on 16/01/2023.
//

import UIKit
import Firebase
import UserNotifications
// To delete: on evite de laisser du code mort/ en commentaire dans du code qui part en production :)
//import BackgroundTasks

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupLocalNotifications()

        // MARK: - Firebase configuration
        
        FirebaseApp.configure()
        
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

    // MARK: User request notifications
    private func setupLocalNotifications() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .notDetermined {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    if granted {
                        let newsViewModel = NewsViewModel()
                        newsViewModel.scheduleDailyNotification()
                    }
                    UserDefaults.standard.set(granted, forKey: "isAllowed")
                }
            }
        }
    }
}


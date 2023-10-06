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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // MARK: - User request notifications
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notifications are allowed")
            } else {
                print("Noticiations are not allowed")
            }
        }
        
        // MARK: - Task register in background
        
        let taskIdentifier = "com.Astropedia.dailyFetchPicture"
        let calendar = Calendar.current
        
        let dateComponents = DateComponents(hour: 11, minute: 00)
        let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
        request.earliestBeginDate = calendar.nextDate(after: Date(), matching: dateComponents, matchingPolicy: .nextTime)
        BGTaskScheduler.shared.register(forTaskWithIdentifier: taskIdentifier, using: nil) { task in
            let newsViewModel = NewsViewModel()
            newsViewModel.fetchPictures()
            task.setTaskCompleted(success: true)
        }
        do {
            try BGTaskScheduler.shared.submit(request)
            print("Task submitted in background")
        } catch {
            print("Error submitted task : \(error)")
        }
        
        
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
}


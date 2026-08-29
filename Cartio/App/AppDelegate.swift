//
//  AppDelegate.swift
//  Cartio
//

import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // TODO: FirebaseApp.configure()
        // TODO: Push notification registration
        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        // TODO: Forward to Firebase Messaging
    }
}

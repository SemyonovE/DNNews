//
//  AppDelegate.swift
//  DNNews
//
//  Created by Evgenii Semenov on 23.12.2019.
//  Copyright © 2019 Evgenii Semenov. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
// MARK: Setup initial viewcontroller with navigation bar
        let navigationController = UINavigationController()
        let initialViewController = NewsViewController()

        navigationController.viewControllers = [initialViewController]
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
        
        return true
    }
}

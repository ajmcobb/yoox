//
//  TestAppDelegate.swift
//  Yoox
//
//  Created by Aurelien Cobb on 07/09/2019.
//  Copyright © 2019 Aurelien Cobb. All rights reserved.
//

import UIKit

class TestAppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow()
        window?.rootViewController = UIViewController()
        window?.makeKeyAndVisible()
        return true
    }
}

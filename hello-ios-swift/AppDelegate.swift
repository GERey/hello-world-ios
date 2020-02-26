//
//  AppDelegate.swift
//  LaunchDarklyHelloWorld
//
//  Created by Korhan Bircan on 3/24/17.
//  Copyright © 2017 Korhan Bircan. All rights reserved.
//

import UIKit
import LaunchDarkly

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    // Enter your mobile key here: Account Settings -> Your Projects -> Production/Test -> Mobile key.
    private let mobileKey = "mob-b0c4d988-e14a-4b9a-b958-8c73c0dccb9d"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        setUpLDClient()

        return true
    }

    private func setUpLDClient() {
        let user = LDUser(key: "test@email.com")

        var config = LDConfig(mobileKey: mobileKey)
//        config.streamingMode = .polling
//        config.flagPollingInterval = 30.0
        config.eventFlushInterval = 30.0
        
//        config.baseUrl = URL(string: "http://localhost:8030")!
//        /// The default url for making event reports
//        config.eventsUrl = URL(string: "http://localhost:8030")!
//        /// The default url for connecting to the *clientstream*
//        config.streamUrl = URL(string: "http://localhost:8030")!

        LDClient.shared.start(config: config, user: user)
    }
}

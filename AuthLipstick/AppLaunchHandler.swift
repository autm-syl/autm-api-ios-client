//
//  AppLaunchHandler.swift
//  AuthLipstick
//
//  Created by Sylvanas on 11/12/19.
//  Copyright © 2019 Sylvanas. All rights reserved.
//

import Foundation
import UIKit

class AppLaunchHandler :NSObject {
    var window: UIWindow?
    static let shared = AppLaunchHandler()
    
    func startRootViewController(window: UIWindow) {
        self.window = window
        window.rootViewController = RootNavigationViewController.init()
    }
}

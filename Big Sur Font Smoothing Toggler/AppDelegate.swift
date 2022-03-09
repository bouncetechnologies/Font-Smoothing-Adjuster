//
//  AppDelegate.swift
//  Big Sur Font Smoothing Toggler
//
//  Created by Alastair Byrne on 16/11/2020.
//

import Cocoa
import AppCenter
import AppCenterAnalytics
import AppCenterCrashes

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var mainWindowController: MainWindowController?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let mainWindowController = MainWindowController()
        mainWindowController.showWindow(self)
        self.mainWindowController = mainWindowController
        
        configureAnalytics()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

extension AppDelegate {
    
    func configureAnalytics() {
        if UserDefaults.disableAnalytics { return }
        
        #if !DEBUG
        let appCenterSecret = AppCenterConfig.secret
        guard appCenterSecret != "" else { fatalError("Failed to get AppCenter secret") }
        AppCenter.start(withAppSecret: appCenterSecret, services: [Analytics.self, Crashes.self])
        guard Analytics.enabled else { fatalError("Failed to enable analytics") }
        #endif
    }
}


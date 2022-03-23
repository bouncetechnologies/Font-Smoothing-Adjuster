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
    var analyticsInitialised = false
    
    @IBAction func sponsorshipButtonPressed(_ sender: NSMenuItem) {
        guard let sponsorshipURL = URL(string: "https://www.buymeacoffee.com/bouncetech") else { return }
        NSWorkspace.shared.open(sponsorshipURL)
    }
    
    @objc dynamic var analyticsEnabled: Bool {
        get {
            configureAnalytics()
            
            return Analytics.enabled
        }
        
        set {
            Analytics.enabled = newValue
            Crashes.enabled = newValue
        }
    }
    
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
        if analyticsInitialised { return }
        
        #if !DEBUG
        let appCenterSecret = AppCenterConfig.secret
        guard appCenterSecret != "" else { fatalError("Failed to get AppCenter secret") }
        
        AppCenter.configure(withAppSecret: appCenterSecret)
        
        if AppCenter.isConfigured {
            AppCenter.startService(Analytics.self)
            AppCenter.startService(Crashes.self)
            analyticsInitialised = true
        }
        #endif
    }
}


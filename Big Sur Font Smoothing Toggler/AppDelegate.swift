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
        
        AppCenter.start(withAppSecret: "6f8e48b9-8342-4653-95a7-49655ea2f048", services: [Analytics.self, Crashes.self])
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}


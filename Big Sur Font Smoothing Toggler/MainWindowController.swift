//
//  MainWindowController.swift
//  Big Sur Font Smoothing Toggler
//
//  Created by Alastair Byrne on 16/11/2020.
//

import Cocoa
import os.log

class MainWindowController: NSWindowController {
    
    @IBOutlet weak var toggleSwitch: NSSwitch!
    
    let fontSmoothingDefaults = FontSmoothingDefaults()
    
    override var windowNibName: NSNib.Name? {
        return NSNib.Name.mainWindowController
    }

    override func windowDidLoad() {
        super.windowDidLoad()

        do {
            let isFontSmoothingEnabled = try fontSmoothingDefaults.isFontSmoothingEnabled()
            toggleSwitch.state = isFontSmoothingEnabled ? .on : .off
        } catch {
            os_log(.error, "Error setting font smoothing defaults: %s", error.localizedDescription)
            presentErrorSheet(error)
        }
    }
    
    @IBAction func toggleFontSmoothing(_ sender: NSSwitch) {
        do {
            switch toggleSwitch.state {
            case .on:
                try fontSmoothingDefaults.enableFontSmoothing()
            case .off:
                try fontSmoothingDefaults.disableFontSmoothing()
            default:
                fatalError("Unsupported toggle switch state.")
            }
        } catch {
            // Revert toggle switch state because error occurred.
            toggleSwitch.state = toggleSwitch.state == .on ? .off : .on
            os_log(.error, "Error setting font smoothing defaults: %s", error.localizedDescription)
            presentErrorSheet(error)
        }
    }
    
    func presentErrorSheet(_ error: Error) {
        guard let window = self.window else { return }
        let alert = NSAlert(error: error)
        alert.messageText = "The operation couldn't be completed"
        alert.informativeText = "An unexpected error occurred. Please view the logs in the Console app for details."
        alert.alertStyle = .critical
        alert.beginSheetModal(for: window)
    }
    
}

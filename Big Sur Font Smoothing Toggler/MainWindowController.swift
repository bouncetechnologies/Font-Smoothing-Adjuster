//
//  MainWindowController.swift
//  Big Sur Font Smoothing Toggler
//
//  Created by Alastair Byrne on 16/11/2020.
//

import Cocoa
import os.log
import AppCenterAnalytics

class MainWindowController: NSWindowController {
    @IBOutlet weak var disabledFontSmoothingRadioButton: NSButton!
    @IBOutlet weak var enabledFontSmoothingRadioButton: NSButton!
    
    private let fontSmoothingDefaults = FontSmoothingDefaults()
    private typealias FontSmoothingOption = FontSmoothingDefaults.FontSmoothingOptions
    
    override var windowNibName: NSNib.Name? {
        return NSNib.Name.mainWindowController
    }

    override func windowDidLoad() {
        super.windowDidLoad()

        setRadioButtonsToCurrentDefaultsState()
    }
    
    private func setRadioButtonsToCurrentDefaultsState() {
        do {
            let currentFontSmoothingState = try fontSmoothingDefaults.getFontSmoothingState()
            updateUIWithState(fontSmoothingState: currentFontSmoothingState)
        } catch {
            os_log(.error, "Error getting font smoothing defaults: %s", error.localizedDescription)
            Analytics.trackEvent("Error getting font smoothing defaults: \(error.localizedDescription)")
            presentErrorSheet(error)
        }
    }
    
    private func updateUIWithState(fontSmoothingState: FontSmoothingOption) {
        switch fontSmoothingState {
        case .disabled:
            disabledFontSmoothingRadioButton.state = .on
        default:
            enabledFontSmoothingRadioButton.state = .on
        }
    }
    
    @IBAction func toggleFontSmoothing(_ sender: NSButton) {
        let newFontSmoothingState: FontSmoothingOption
        switch sender {
        case disabledFontSmoothingRadioButton:
            newFontSmoothingState = .disabled
        case enabledFontSmoothingRadioButton:
            newFontSmoothingState = .enabled
        default:
            Analytics.trackEvent("Unsupported font smoothing radio button option selected")
            fatalError("Unsupported font smoothing radio button option selected.")
        }
        do {
            let currentFontSmoothingState = try fontSmoothingDefaults.getFontSmoothingState()
            guard newFontSmoothingState != currentFontSmoothingState else {
                return
            }
                       
            try updateFontSmoothingPreferences(newState: newFontSmoothingState, oldState: currentFontSmoothingState)
            
            Analytics.trackEvent("Font smoothing preferences updated")
            presentSuccessSheet()
        } catch {
            // Revert toggle switch state because error occurred.
            setRadioButtonsToCurrentDefaultsState()
            os_log(.error, "Error setting font smoothing defaults: %s", error.localizedDescription)
            Analytics.trackEvent("Error setting font smoothing defaults: \(error.localizedDescription)")
            presentErrorSheet(error)
        }
    }
    
    private func updateFontSmoothingPreferences(newState: FontSmoothingOption, oldState: FontSmoothingOption) throws {
        try fontSmoothingDefaults.setFontSmoothing(option: newState)
        setRadioButtonsToCurrentDefaultsState()
        window?.undoManager?.registerUndo(withTarget: self, handler: { target in
            try? target.undoUpdateFontSmoothingPreferences(oldState: oldState, newState: newState)
            target.setRadioButtonsToCurrentDefaultsState()
        })
    }
    
    private func undoUpdateFontSmoothingPreferences(oldState: FontSmoothingOption, newState: FontSmoothingOption) throws {
        try fontSmoothingDefaults.setFontSmoothing(option: oldState)
        setRadioButtonsToCurrentDefaultsState()
        window?.undoManager?.registerUndo(withTarget: self, handler: { target in
            try? target.updateFontSmoothingPreferences(newState: newState, oldState: oldState)
            target.setRadioButtonsToCurrentDefaultsState()
        })
    }
    
    private func presentSuccessSheet() {
        guard let window = self.window else { return }
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("Font smoothing preferences successfully updated", comment: "Title for preferences update success sheet modal")
        alert.informativeText = NSLocalizedString("Log out or restart your Mac for the changes to take effect.", comment: "Informative text for preferences update success sheet modal")
        alert.addButton(withTitle: NSLocalizedString("Log out now", comment: "Log out now button text"))
        alert.addButton(withTitle: NSLocalizedString("Log out later", comment: "Log out later button text"))
        alert.alertStyle = .informational
        alert.beginSheetModal(for: window) { (response) in
            switch response {
            case .alertFirstButtonReturn:
                let source = """
                tell application "System Events"

                    log out

                end tell
                """
                
                guard let script = NSAppleScript(source: source) else { return }
                var error: NSDictionary?
                script.executeAndReturnError(&error)
                if let error = error {
                    print(error)
                    os_log(.error, "Error logging out user")
                    Analytics.trackEvent("Error logging out user")
                }
            case .alertSecondButtonReturn:
                return
            default:
                Analytics.trackEvent("Unsupported action taken on success sheet.")
                fatalError("Unsupported action taken on success sheet.")
            }
        }
    }
    
    private func presentErrorSheet(_ error: Error) {
        guard let window = self.window else { return }
        let alert = NSAlert(error: error)
        alert.messageText = NSLocalizedString("The operation couldn't be completed", comment: "Title for error sheet")
        alert.informativeText = NSLocalizedString("An unexpected error occurred. Please view the logs in the Console app for details.", comment: "Informative text for error sheet")
        alert.alertStyle = .critical
        alert.beginSheetModal(for: window)
    }
}

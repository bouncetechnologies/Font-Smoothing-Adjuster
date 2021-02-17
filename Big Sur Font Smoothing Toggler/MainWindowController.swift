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
    @IBOutlet weak var lightFontSmoothingRadioButton: NSButton!
    @IBOutlet weak var mediumFontSmoothingRadioButton: NSButton!
    @IBOutlet weak var heavyFontSmoothingRadioButton: NSButton!
    
    let fontSmoothingDefaults = FontSmoothingDefaults()
    
    override var windowNibName: NSNib.Name? {
        return NSNib.Name.mainWindowController
    }

    override func windowDidLoad() {
        super.windowDidLoad()

        setRadioButtonsToCurrentDefaultsState()
    }
    
    func setRadioButtonsToCurrentDefaultsState() {
        do {
            let fontSmoothingState = try fontSmoothingDefaults.getFontSmoothingState()
            switch fontSmoothingState {
            case .noFontSmoothing:
                disabledFontSmoothingRadioButton.state = .on
            case .lightFontSmoothing:
                lightFontSmoothingRadioButton.state = .on
            case .mediumFontSmoothing:
                mediumFontSmoothingRadioButton.state = .on
            case .heavyFontSmoothing:
                heavyFontSmoothingRadioButton.state = .on
            }
        } catch {
            os_log(.error, "Error getting font smoothing defaults: %s", error.localizedDescription)
            Analytics.trackEvent("Error getting font smoothing defaults: \(error.localizedDescription)")
            presentErrorSheet(error)
        }
            
    }
    
    @IBAction func toggleFontSmoothing(_ sender: NSButton) {
        let fontSmoothingOption: FontSmoothingDefaults.FontSmoothingOptions
        switch sender {
        case disabledFontSmoothingRadioButton:
            fontSmoothingOption = .noFontSmoothing
        case lightFontSmoothingRadioButton:
            fontSmoothingOption = .lightFontSmoothing
        case mediumFontSmoothingRadioButton:
            fontSmoothingOption = .mediumFontSmoothing
        case heavyFontSmoothingRadioButton:
            fontSmoothingOption = .heavyFontSmoothing
        default:
            Analytics.trackEvent("Unsupported font smoothing radio button option selected")
            fatalError("Unsupported font smoothing radio button option selected.")
        }
        do {
            let fontSmoothingState = try fontSmoothingDefaults.getFontSmoothingState()
            guard fontSmoothingOption != fontSmoothingState else {
                return
            }
            try fontSmoothingDefaults.setFontSmoothing(option: fontSmoothingOption)
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
    
    func presentSuccessSheet() {
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
    
    func presentErrorSheet(_ error: Error) {
        guard let window = self.window else { return }
        let alert = NSAlert(error: error)
        alert.messageText = NSLocalizedString("The operation couldn't be completed", comment: "Title for error sheet")
        alert.informativeText = NSLocalizedString("An unexpected error occurred. Please view the logs in the Console app for details.", comment: "Informative text for error sheet")
        alert.alertStyle = .critical
        alert.beginSheetModal(for: window)
    }
}

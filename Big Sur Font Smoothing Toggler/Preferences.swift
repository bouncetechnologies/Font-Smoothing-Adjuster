//
//  Preferences.swift
//  Font Smoothing Adjuster
//
//  Created by Alastair Byrne on 09/03/2022.
//

import Foundation

extension UserDefaults {
    
    private enum Keys {
        static let disableAnalytics = "DisableAnalytics"
    }
    
    class var disableAnalytics: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.disableAnalytics)
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.disableAnalytics)
        }
    }
}

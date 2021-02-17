//
//  FontSmoothingDefaults.swift
//  Big Sur Font Smoothing Toggler
//
//  Created by Alastair Byrne on 16/11/2020.
//

import Foundation
import os.log

class FontSmoothingDefaults {
        
    enum FontSmoothingOptions: Int {
        case noFontSmoothing = 0
        case lightFontSmoothing = 1
        case mediumFontSmoothing = 2
        case heavyFontSmoothing = 3
    }
    
    func setFontSmoothing(option: FontSmoothingOptions) throws {
        let value = option.rawValue as CFNumber
        let key = CFPreferencesConstants.key
        let applicationID = CFPreferencesConstants.applicationID
        let userName = CFPreferencesConstants.userName
        let hostName = CFPreferencesConstants.hostName
        
        CFPreferencesSetValue(key, value, applicationID, userName, hostName)
        let result = CFPreferencesSynchronize(applicationID, userName, hostName)
        guard result else {
            throw FontSmoothingDefaultsError.unknownError
        }
    }
    
    func getFontSmoothingState() throws -> FontSmoothingOptions {
        let value = CFPreferencesCopyAppValue(CFPreferencesConstants.key, CFPreferencesConstants.applicationID) as? Int ?? 2
        
        guard let option = FontSmoothingOptions(rawValue: value) else {
            throw FontSmoothingDefaultsError.unknownError
        }
        
        return option
    }
    
    private enum FontSmoothingDefaultsError: Error {
        case unknownError
    }
    
    private struct CFPreferencesConstants {
        static let key = "AppleFontSmoothing" as CFString
        static let applicationID = kCFPreferencesAnyApplication
        static let userName = kCFPreferencesCurrentUser
        static let hostName = kCFPreferencesCurrentHost
    }
}

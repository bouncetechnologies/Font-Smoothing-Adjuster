//
//  Config.swift
//  Font Smoothing Adjuster
//
//  Created by Alastair Byrne on 01/02/2021.
//

import Foundation

enum Configuration {
    enum Error: Swift.Error {
        case missingKey, invalidValue
    }

    static func value<T>(for key: String) throws -> T where T: LosslessStringConvertible {
        guard let object = Bundle.main.object(forInfoDictionaryKey:key) else {
            throw Error.missingKey
        }

        switch object {
        case let value as T:
            return value
        case let string as String:
            guard let value = T(string) else { fallthrough }
            return value
        default:
            throw Error.invalidValue
        }
    }
}

enum AppCenterConfig {
    static var secret: String {
        return try! Configuration.value(for: "APP_CENTER_SECRET")
    }
}

//
//  FontSmoothingDefaults.swift
//  Big Sur Font Smoothing Toggler
//
//  Created by Alastair Byrne on 16/11/2020.
//

import Foundation
import os.log

class FontSmoothingDefaults {
    
    private let defaultsUrl = URL(fileURLWithPath: "/usr/bin/defaults")
    private let domainDefaultPairDoesNotExistText = "The domain/default pair of (kCFPreferencesAnyApplication, AppleFontSmoothing) does not exist"
    
    let defaultsProcessArguments: [Args : [String]] = [
        .enableFontSmoothing : ["-currentHost", "delete", "-g", "AppleFontSmoothing"],
        .disableFontSmoothing : ["-currentHost", "write", "-g", "AppleFontSmoothing", "-int", "0"],
        .getFontSmoothingState : ["-currentHost", "read", "Apple Global Domain", "AppleFontSmoothing"],
    ]
    
    enum Args {
        case enableFontSmoothing
        case disableFontSmoothing
        case getFontSmoothingState
    }
    
    private struct Result {
        let output: String
        let error: String
    }
    
    enum FontSmoothingDefaultsError: Error {
        case unknownError
    }
    
    func isFontSmoothingEnabled() throws -> Bool {
        do {
            let result = try runDefaultsCommand(with: .getFontSmoothingState)
            
            if result.output == "0\n" {
                return false
            }
            
            if result.output.contains(domainDefaultPairDoesNotExistText) || result.error.contains(domainDefaultPairDoesNotExistText) {
                return true
            }
            
            throw FontSmoothingDefaultsError.unknownError
        } catch {
            if error.localizedDescription.contains(domainDefaultPairDoesNotExistText) {
                return true
            } else {
                throw error
            }
        }
    }
    
    func enableFontSmoothing() throws {
        do {
            let result = try runDefaultsCommand(with: .enableFontSmoothing)
            
            if result.output != "" || result.error != "" {
                throw FontSmoothingDefaultsError.unknownError
            }
        } catch {
            if !error.localizedDescription.contains(domainDefaultPairDoesNotExistText) {
                throw error
            }
        }
    }
    
    func disableFontSmoothing() throws {
        let result = try runDefaultsCommand(with: .disableFontSmoothing)
        
        if result.output != "" || result.error != "" {
            throw FontSmoothingDefaultsError.unknownError
        }
    }
    
    private func runDefaultsCommand(with arguments: Args) throws -> Result {
        guard let args = defaultsProcessArguments[arguments] else {
            fatalError("Unsupported arguments passed to runDefaultsCommand")
        }
        
        let task = Process()
        
        task.executableURL = defaultsUrl
        task.arguments = args

        let outputPipe = Pipe()
        let errorPipe = Pipe()

        task.standardOutput = outputPipe
        task.standardError = errorPipe
        
        try task.run()
        
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()

        let output = String(decoding: outputData, as: UTF8.self)
        let error = String(decoding: errorData, as: UTF8.self)

        os_log(.debug, "Output: %s", output)
        os_log(.debug, "Error: %s", error)
        
        let result = Result(output: output, error: error)
        return result
    }

}

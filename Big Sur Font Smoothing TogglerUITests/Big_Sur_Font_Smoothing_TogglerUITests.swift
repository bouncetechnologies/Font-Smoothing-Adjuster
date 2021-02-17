//
//  Big_Sur_Font_Smoothing_TogglerUITests.swift
//  Big Sur Font Smoothing TogglerUITests
//
//  Created by Alastair Byrne on 16/11/2020.
//

import XCTest

class Big_Sur_Font_Smoothing_TogglerUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        
        // Record initial state so we can restore it during teardown
        initialState = try! runDefaultsCommand(with: getFontSmoothingStateArguments)
        print("Initial state of defaults preferences: \(String(describing: initialState))")
        
        // Delete the AppleFontSmoothing preference so the initial state is the
        // same as the default macOS Big Sur state for this preference
        let arguments = ["-currentHost", "delete", "-g", "AppleFontSmoothing"]
        let _ = try! runDefaultsCommand(with: arguments)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
        if initialState!.error.contains("The domain/default pair of (kCFPreferencesAnyApplication, AppleFontSmoothing) does not exist") {
            // If the initial state was that no font smoothing preference was set, then ensure that
            // any preferences from the tests are deleted
            let arguments = ["-currentHost", "delete", "-g", "AppleFontSmoothing"]
            let _ = try! runDefaultsCommand(with: arguments)
        } else {
            // Otherwise set to the preference recorded in the initial state
            let value = initialState!.output.split(separator: "\n")[0]
            let arguments = ["-currentHost", "write", "-g", "AppleFontSmoothing", "-int", "\(value)"]
            let _ = try! runDefaultsCommand(with: arguments)
        }
    }

    func testUI() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launchArguments = ["enable-testing"]
        app.launch()

        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let bigSurFontSmoothingTogglerWindow = XCUIApplication().windows["Font Smoothing Adjuster"]
        bigSurFontSmoothingTogglerWindow.radioButtons["Light"].click()
        let logOutLaterButton = bigSurFontSmoothingTogglerWindow.sheets["alert"].buttons["Log out later"]
        logOutLaterButton.click()
        let lightResult = try? runDefaultsCommand(with: getFontSmoothingStateArguments)
        XCTAssert(lightResult?.output == "1\n")
        
        bigSurFontSmoothingTogglerWindow.radioButtons["Medium (default)"].click()
        logOutLaterButton.click()
        let mediumResult = try? runDefaultsCommand(with: getFontSmoothingStateArguments)
        XCTAssert(mediumResult?.output == "2\n")
        
        bigSurFontSmoothingTogglerWindow.radioButtons["Heavy"].click()
        logOutLaterButton.click()
        let heavyResult = try? runDefaultsCommand(with: getFontSmoothingStateArguments)
        XCTAssert(heavyResult?.output == "3\n")
        
        bigSurFontSmoothingTogglerWindow.radioButtons["Disabled"].click()
        logOutLaterButton.click()
        let disabledResult = try? runDefaultsCommand(with: getFontSmoothingStateArguments)
        XCTAssert(disabledResult?.output == "0\n")
    }
    
    private let getFontSmoothingStateArguments = ["-currentHost", "read", "Apple Global Domain", "AppleFontSmoothing"]
    private var initialState: DefaultsResult?
    
    private struct DefaultsResult {
        let output: String
        let error: String
    }
    
    private func runDefaultsCommand(with arguments: [String]) throws -> DefaultsResult {
        let task = Process()
        
        task.executableURL = URL(fileURLWithPath: "/usr/bin/defaults")
        task.arguments = arguments

        let outputPipe = Pipe()
        let errorPipe = Pipe()

        task.standardOutput = outputPipe
        task.standardError = errorPipe
        
        try task.run()
        
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()

        let output = String(decoding: outputData, as: UTF8.self)
        let error = String(decoding: errorData, as: UTF8.self)
        
        let result = DefaultsResult(output: output, error: error)
        return result
    }
}

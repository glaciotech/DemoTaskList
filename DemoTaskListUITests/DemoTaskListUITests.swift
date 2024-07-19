//
//  DemoTaskListUITests.swift
//  DemoTaskListUITests
//
//  Created by Peter Liddle on 6/27/24.
//

import XCTest

final class DemoTaskListUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        // Do any setup to get the app in the correct state for the screen you want to get the view hierarchy of or test
        // We don't need any setup for this test app so we just create a clean instance of the app
        app = XCUIApplication()
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        app = nil
    }
    
    
    // --- uitesting.tools methods ---

    private func copyViewStructureToClipboard() {
        let viewHierachy = XCUIApplication().debugDescription
        print(viewHierachy)
        
    #if os(macOS)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(viewHierachy, forType: .string)
    #else
        let pasteboard = UIPasteboard.general
        pasteboard.string = viewHierachy
    #endif
    }
    
    func testCopyViewStructure() {
        app.launch()
        copyViewStructureToClipboard()
    }
    
    // ---
    

    // Place any tests you create with uitesting.tools here to try.
    // TIP: After pasting hit cmd-s to save file and have xcode recognize the test for running
    
    
    /// Use this to get a screenshot of the app to use as a reference when asking for tests
#if os(macOS)
    func testTakeScreenshotOfMainPage() {
       // Launch the application
       app.launch()
       
       // Wait for the main window to appear
       let mainWindow = app.windows["DemoTaskList.ContentView-1-AppWindow-1"]
       let exists = NSPredicate(format: "exists == true")
       expectation(for: exists, evaluatedWith: mainWindow, handler: nil)
       waitForExpectations(timeout: 5, handler: nil)
       
       // Take a screenshot of the main window
       let screenshot = mainWindow.screenshot()
       
       // Attach the screenshot to the test report
       let attachment = XCTAttachment(screenshot: screenshot)
       attachment.name = "Screenshot of Main Page on macOS"
       attachment.lifetime = .keepAlways
       add(attachment)
   }
    
    // ADD macOS generated tests here
    #warning("Add macOS generated tests here")
    
#elseif os(iOS)
    func testTakeScreenshotOfMainPage() {
        // Launch the application
        app.launch()

        // Wait for the main page to load
        let collectionView = app.collectionViews.firstMatch
        let exists = NSPredicate(format: "exists == true")
        expectation(for: exists, evaluatedWith: collectionView, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)

        // Take a screenshot of the main page
        let screenshot = app.screenshot()
        
        // Attach the screenshot to the test report
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "Screenshot of Main Page"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    // ADD iOS generated tests here
    #warning("Add iOS generated tests here")
#endif
}

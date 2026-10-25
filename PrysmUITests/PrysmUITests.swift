//
//  PrysmUITests.swift
//  PrysmUITests
//
//  Created by Andrew Bierman on 10/15/25.
//

import XCTest

final class PrysmUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}

final class AdaptiveRefreshAcceptanceTests: XCTestCase {
    @MainActor
    func testDraftAndSelectionsAcrossOrientation() throws {
        continueAfterFailure = false
        try XCTSkipUnless(
            ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] == "iPhone18,2",
            "Requires iPhone 17 Pro Max simulator for compact portrait / regular landscape coverage"
        )
        let app = XCUIApplication()
        XCUIDevice.shared.orientation = .portrait
        addTeardownBlock {
            app.terminate()
            XCUIDevice.shared.orientation = .portrait
        }
        app.launch()
        func capture(_ name: String) {
            let shot = XCTAttachment(screenshot: app.screenshot())
            shot.name = name
            shot.lifetime = .keepAlways
            add(shot)
            let screen = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
            screen.name = name + " full screen"
            screen.lifetime = .keepAlways
            add(screen)
            let tree = XCTAttachment(string: app.debugDescription)
            tree.name = name + " hierarchy"
            tree.lifetime = .keepAlways
            add(tree)
        }
        capture("Initial model and welcome state")
        if app.buttons["Skip"].waitForExistence(timeout: 5) { app.buttons["Skip"].tap() }
        if app.buttons["Continue Anyway"].waitForExistence(timeout: 3) {
            XCTAssertTrue(app.staticTexts["Apple Intelligence Not Available"].exists)
            capture("Model unavailable")
            app.buttons["Continue Anyway"].tap()
        }
        let input = app.textFields.firstMatch
        XCTAssertTrue(input.waitForExistence(timeout: 5))
        input.tap()
        input.typeText("Synthetic draft stays 42")
        XCTAssertEqual(input.value as? String, "Synthetic draft stays 42")
        capture("Portrait draft")
        app.buttons["Instructions"].tap()
        XCTAssertTrue(app.navigationBars["Custom Instructions"].waitForExistence(timeout: 5))
        capture("Instructions sheet")
        app.buttons["Cancel"].tap()
        XCTAssertTrue(input.waitForExistence(timeout: 5))
        XCTAssertEqual(input.value as? String, "Synthetic draft stays 42")
        XCTAssertTrue(app.buttons["Dismiss keyboard"].waitForExistence(timeout: 5))
        let dismiss = app.buttons["Dismiss keyboard"]
        XCTAssertGreaterThanOrEqual(dismiss.frame.width, 44)
        XCTAssertGreaterThanOrEqual(dismiss.frame.height, 44)
        dismiss.coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.1)).tap()
        XCTAssertTrue(app.keyboards.firstMatch.waitForNonExistence(timeout: 5))
        capture("Keyboard dismissed")
        app.tabBars.buttons["Assistant"].tap()
        app.segmentedControls.buttons["Tools"].tap()
        app.tabBars.buttons["Model"].tap()
        app.segmentedControls.buttons["Parameters"].tap()
        app.tabBars.buttons["Assistant"].tap()
        XCTAssertTrue(app.segmentedControls.buttons["Tools"].isSelected)
        app.tabBars.buttons["Model"].tap()
        XCTAssertTrue(app.segmentedControls.buttons["Parameters"].isSelected)
        app.tabBars.buttons["Chat"].tap()
        XCTAssertEqual(input.value as? String, "Synthetic draft stays 42")
        XCUIDevice.shared.orientation = .landscapeLeft
        let landscape = NSPredicate { _, _ in app.frame.width > app.frame.height }
        expectation(for: landscape, evaluatedWith: app)
        waitForExpectations(timeout: 5)
        let settled = expectation(description: "Rotation animation settled")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { settled.fulfill() }
        wait(for: [settled], timeout: 3)
        XCTAssertTrue(app.buttons["Dismiss keyboard"].waitForExistence(timeout: 5))
        app.buttons["Dismiss keyboard"].tap()
        XCTAssertTrue(app.keyboards.firstMatch.waitForNonExistence(timeout: 5))
        capture("Landscape navigation")
        // A real regular-width branch must replace the compact tab bar.
        XCTAssertFalse(app.tabBars.firstMatch.exists, "Rotation did not establish regular-width navigation")
        XCTAssertEqual(app.textFields.firstMatch.value as? String, "Synthetic draft stays 42")
        XCUIDevice.shared.orientation = .portrait
        XCTAssertTrue(app.tabBars.buttons["Chat"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.textFields.firstMatch.value as? String, "Synthetic draft stays 42")
        input.tap()
        capture("Returned portrait draft")
        XCTAssertTrue(app.buttons["Dismiss keyboard"].waitForExistence(timeout: 5))
        app.buttons["Dismiss keyboard"].tap()
        XCTAssertTrue(app.keyboards.firstMatch.waitForNonExistence(timeout: 5))
        app.tabBars.buttons["Assistant"].tap()
        XCTAssertTrue(app.segmentedControls.buttons["Tools"].isSelected)
        capture("Assistant selection after rotation")
        app.tabBars.buttons["Model"].tap()
        XCTAssertTrue(app.segmentedControls.buttons["Parameters"].isSelected)
        capture("Model selection after rotation")
    }
}

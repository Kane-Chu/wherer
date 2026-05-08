//
//  WhererUITests.swift
//  WhererUITests
//
//  Created by 楚家明 on 2026/5/9.
//

import XCTest

final class WhererUITests: XCTestCase {

    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        setupSnapshot(app)
        app.launch()
    }

    func testScreenshots() throws {
        sleep(2)
        snapshot("01_Home")

        let addButton = app.buttons["addItemButton"]
        if addButton.waitForExistence(timeout: 3) {
            addButton.tap()
            sleep(1)
            snapshot("02_AddItem")

            let cancelButton = app.buttons["itemFormCancelButton"]
            if cancelButton.waitForExistence(timeout: 3) {
                cancelButton.tap()
                sleep(1)
            }
        }

        let spaceTab = app.tabBars.buttons["空间"]
        if spaceTab.waitForExistence(timeout: 3) {
            spaceTab.tap()
            sleep(1)
            snapshot("03_Spaces")
        }
    }
}

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

        // 1. 空间首页
        snapshot("01_Spaces")

        // 2. 物品列表
        let itemsTab = app.tabBars.buttons["物品"]
        if itemsTab.waitForExistence(timeout: 3) {
            itemsTab.tap()
            sleep(1)
            snapshot("02_Items")
        }

        // 3. 添加物品表单（如果有数据才能点添加按钮）
        let addButton = app.buttons["addItemButton"]
        if addButton.waitForExistence(timeout: 3) && addButton.isEnabled {
            addButton.tap()
            sleep(1)
            snapshot("03_AddItem")

            // 返回
            let cancelButton = app.buttons["itemFormCancelButton"]
            if cancelButton.waitForExistence(timeout: 3) {
                cancelButton.tap()
                sleep(1)
            }
        }

        // 4. 设置页
        let settingsTab = app.tabBars.buttons["设置"]
        if settingsTab.waitForExistence(timeout: 3) {
            settingsTab.tap()
            sleep(1)
            snapshot("04_Settings")
        }
    }
}

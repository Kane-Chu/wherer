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
        app.launchArguments = ["-screenshotData"]
        setupSnapshot(app)
        app.launch()
    }

    private func switchToTab(_ name: String) {
        let tab = app.tabBars.buttons[name]
        XCTAssertTrue(tab.waitForExistence(timeout: 3))
        tab.tap()
        sleep(1)
    }

    // MARK: - 截图测试

    func testScreenshots() throws {
        sleep(2)

        // 1. 空间首页 - 网格模式
        snapshot("01_Spaces_Grid")

        // 2. 空间列表模式
        let viewToggle = app.buttons["viewToggleButton"]
        if viewToggle.waitForExistence(timeout: 3) {
            viewToggle.tap()
            sleep(1)
            snapshot("02_Spaces_List")
        }

        // 3. 物品首页 - 网格模式
        switchToTab("物品")
        snapshot("03_Items_Grid")

        // 4. 物品列表模式
        if viewToggle.waitForExistence(timeout: 3) {
            viewToggle.tap()
            sleep(1)
            snapshot("04_Items_List")
        }

        // 5. 添加物品表单
        let addItemButton = app.buttons["addItemButton"]
        XCTAssertTrue(addItemButton.waitForExistence(timeout: 3))
        addItemButton.tap()
        sleep(1)
        snapshot("05_AddItem")

        // 返回
        app.navigationBars["添加物品"].buttons["取消"].tap()
        sleep(1)

        // 6. 物品详情页
        let firstItem = app.staticTexts["手机充电器"]
        if firstItem.waitForExistence(timeout: 3) {
            firstItem.tap()
            sleep(1)
            snapshot("06_ItemDetail")

            // 返回
            if app.buttons["itemDetailBackButton"].waitForExistence(timeout: 3) {
                app.buttons["itemDetailBackButton"].tap()
                sleep(1)
            }
        }

        // 7. 空间详情页
        switchToTab("空间")
        let firstSpace = app.staticTexts["卧室"]
        if firstSpace.waitForExistence(timeout: 3) {
            firstSpace.tap()
            sleep(1)
            snapshot("07_SpaceDetail")

            // 返回
            if app.buttons["返回"].waitForExistence(timeout: 3) {
                app.buttons["返回"].tap()
                sleep(1)
            }
        }

        // 8. 设置页
        switchToTab("设置")
        snapshot("08_Settings")
    }
}

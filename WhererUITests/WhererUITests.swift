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

    // MARK: - 辅助方法

    private func addSpace(name: String, iconIndex: Int) {
        let addButton = app.navigationBars["放哪了"].buttons.firstMatch
        XCTAssertTrue(addButton.waitForExistence(timeout: 3))
        addButton.tap()
        sleep(1)

        let nameField = app.textFields["空间名称"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 3))
        nameField.tap()
        nameField.typeText(name)

        let saveButton = app.buttons["保存"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 3))
        saveButton.tap()
        sleep(1)
    }

    private func addItem(name: String, location: String) {
        let addButton = app.buttons["addItemButton"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 3))
        addButton.tap()
        sleep(1)

        let nameField = app.textFields["itemNameField"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 3))
        nameField.tap()
        nameField.typeText(name)

        let locationField = app.textFields["itemLocationField"]
        XCTAssertTrue(locationField.waitForExistence(timeout: 3))
        locationField.tap()
        locationField.typeText(location)

        let saveButton = app.buttons["itemFormSaveButton"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 3))
        saveButton.tap()
        sleep(1)
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

        // ========== 准备数据 ==========

        // 添加空间
        addSpace(name: "卧室", iconIndex: 1)
        addSpace(name: "客厅", iconIndex: 3)
        addSpace(name: "厨房", iconIndex: 6)

        // 切换到物品页，添加物品
        switchToTab("物品")

        addItem(name: "手机充电器", location: "床头柜第二层")
        addItem(name: "护照", location: "客厅电视柜抽屉")
        addItem(name: "感冒药", location: "卧室衣柜上层")
        addItem(name: "笔记本电脑", location: "客厅茶几下面")
        addItem(name: "身份证", location: "卧室书桌抽屉")

        // ========== 开始截图 ==========

        // 1. 空间首页 - 网格模式
        switchToTab("空间")
        snapshot("01_Spaces_Grid")

        // 2. 空间列表模式
        let listToggle = app.buttons["list.bullet"]
        if listToggle.waitForExistence(timeout: 3) {
            listToggle.tap()
            sleep(1)
            snapshot("02_Spaces_List")
        }

        // 3. 物品首页 - 网格模式
        switchToTab("物品")
        snapshot("03_Items_Grid")

        // 4. 物品列表模式
        if listToggle.waitForExistence(timeout: 3) {
            listToggle.tap()
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
        app.buttons["itemFormCancelButton"].tap()
        sleep(1)

        // 6. 物品详情页
        let firstItem = app.staticTexts["手机充电器"]
        if firstItem.waitForExistence(timeout: 3) {
            firstItem.tap()
            sleep(1)
            snapshot("06_ItemDetail")

            // 返回
            if app.buttons["返回"].waitForExistence(timeout: 3) {
                app.buttons["返回"].tap()
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

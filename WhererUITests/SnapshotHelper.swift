import Foundation
import XCTest

var app: XCUIApplication!

func setupSnapshot(_ application: XCUIApplication) {
    app = application
}

func snapshot(_ name: String, timeWaitingForIdle timeout: TimeInterval = 20) {
    sleep(1) // 等待 UI 稳定
    let screenshot = app.windows.firstMatch.screenshot()
    guard let simulator = ProcessInfo().environment["SIMULATOR_DEVICE_NAME"], let language = Locale.current.languageCode else { return }
    let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("screenshots")
        .appendingPathComponent(language)
        .appendingPathComponent(simulator.replacingOccurrences(of: " ", with: ""))
    try? FileManager.default.createDirectory(at: path, withIntermediateDirectories: true)
    let fileURL = path.appendingPathComponent("\(name).png")
    try? screenshot.pngRepresentation.write(to: fileURL)
}

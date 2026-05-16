import OSLog

enum AppLogger {
    private static let logger = Logger(subsystem: "com.kane.wherer", category: "app")

    static func error(_ message: String) {
        logger.error("\(message, privacy: .public)")
    }

    static func info(_ message: String) {
        logger.info("\(message, privacy: .public)")
    }
}

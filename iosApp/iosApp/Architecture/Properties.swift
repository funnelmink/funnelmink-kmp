import Foundation

enum Properties {
    static let appVersion: String = { Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String }()
    static let baseURL: String = { Bundle.main.infoDictionary!["BASE_URL"] as! String }()
    static let isDevEnvironment: Bool = { baseURL.contains("dev.funnelmink") }()
}

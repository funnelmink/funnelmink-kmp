import Foundation
import Shared

// MARK: - Logger

extension Logger {
    /// Standard informational message.
    static func log(_ message: String) {
        Utilities.shared.logger.log(level: .info, message: message)
    }
    
    /// Things that can happen, but we prefer they don't. Request failed, user entered invalid data, etc.
    static func logWarning(_ message: String) {
        Utilities.shared.logger.log(level: .warn, message: message)
    }
    
    /// Critical error. Things that should never happen. When we find these, we fix them.
    static func logError(_ message: String) {
        Utilities.shared.logger.log(level: .error, message: message)
    }
}


// MARK: - Localizer

extension Localizer {
    static func localize(_ key: String) -> String {
        Utilities.shared.localizer.string(key: key)
    }
}


// MARK: - Validator

extension Validator {
    static func isValidName(_ name: String) -> Bool {
        Utilities.shared.validator.isName(input: name)
    }
    
    static func isValidPhoneNumber(_ number: String) -> Bool {
        Utilities.shared.validator.isPhoneNumber(input: number)
    }
    
    static func isValidEmail(_ email: String) -> Bool {
        Utilities.shared.validator.isEmail(input: email)
    }
}

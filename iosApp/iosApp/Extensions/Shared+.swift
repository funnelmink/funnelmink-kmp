import Foundation
import Shared

// MARK: - Logger

extension Logger {
    /// Standard informational message.
    static func info(_ message: String) {
        Utilities.shared.logger.log(level: .info, message: message)
    }
    
    /// Things that can happen, but we prefer they don't. Request failed, user entered invalid data, etc.
    static func warning(_ message: String) {
        Utilities.shared.logger.log(level: .warn, message: message)
    }
    
    /// Things that can happen, but we prefer they don't. Request failed, user entered invalid data, etc.
    static func warning(_ error: Error) {
        Utilities.shared.logger.log(level: .error, message: error.localizedDescription)
    }
    
    /// Critical error. Things that should never happen. When we find these, we fix them.
    static func error(_ message: String) {
        Utilities.shared.logger.log(level: .error, message: message)
    }
    
    /// Critical error. Things that should never happen. When we find these, we fix them.
    static func error(_ error: Error) {
        Utilities.shared.logger.log(level: .error, message: error.localizedDescription)
    }
    
    /// Only used when the user visits a new view.
    static func view(_ name: String) {
        Utilities.shared.logger.view(message: name)
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

// MARK: - Types

extension AccountType {
    var iconName: String {
        switch self {
        case .individual: return "person"
        case .organization: return "building.2"
        }
    }
}

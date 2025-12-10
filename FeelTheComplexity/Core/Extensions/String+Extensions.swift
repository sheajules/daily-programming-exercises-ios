import Foundation

extension String {
    func localizedCaseInsensitiveContains(_ string: String) -> Bool {
        return self.localizedStandardContains(string)
    }
}

extension StringProtocol {
    func localizedStandardContains<S: StringProtocol>(_ string: S) -> Bool {
        return self.localizedLowercase.contains(string.localizedLowercase)
    }
    
    var localizedLowercase: String {
        return self.lowercased(with: Locale.current)
    }
}

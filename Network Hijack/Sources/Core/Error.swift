import Foundation

extension NetworkHijack {
    public struct Error: LocalizedError {
        public private(set) var message: String
        public private(set) var error: Swift.Error?
        
        public var errorDescription: String? {
            return self.message
        }
        
        init(error: Swift.Error? = nil, message: String) {
            self.error = error
            self.message = message
        }
    }
}

extension NetworkHijack.Error: Equatable {
    public static func == (lhs: NetworkHijack.Error, rhs: NetworkHijack.Error) -> Bool {
        return lhs.error?.localizedDescription == rhs.error?.localizedDescription &&
               lhs.message.caseInsensitiveCompare(rhs.message) == .orderedSame
    }
}

extension NetworkHijack.Error {
    static let noResponseFound = NetworkHijack.Error(message: "No route response found")
}

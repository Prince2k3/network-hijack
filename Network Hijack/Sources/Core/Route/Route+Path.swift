import Foundation

extension Route {
    public struct Path: Hashable {
        public let value: String
        public let httpMethod: Route.HTTPMethod
        
        public init(_ value: String, httpMethod: HTTPMethod) {
            self.value = value
            self.httpMethod = httpMethod
        }
        
        public func absolutePath(baseURL: URL) -> URL {
            return baseURL.appendingPathComponent(value)
        }
    }
}

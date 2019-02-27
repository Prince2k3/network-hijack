import Foundation

public protocol Routable {
    static var routes: [Route] { get }
}

extension Routable {
    public static func path(for filename: String, bundle: Bundle = .main) -> String {
        return bundle.path(forResource: filename, ofType: nil) ?? ""
    }
}

public struct Route {
    public enum HTTPMethod: String {
        case get, post, delete, put, patch
    }
    
    public struct Path: RawRepresentable, Hashable {
        public let rawValue: String
        
        public init(_ rawValue: String) {
            self.rawValue = rawValue
        }
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public func absolutePath(_ baseURL: URL) -> URL {
            return baseURL.appendingPathComponent(self.rawValue)
        }
    }
    
    public var path: Path
    public var baseURL: URL
    public var httpMethod: HTTPMethod
    public var response: ResponseProtocol?
    public var routeURL: URL {
        return self.path.absolutePath(self.baseURL)
    }
    
    private var routeComponents: [Route.Component]
    
    public init(baseURL: URL, path: Path, httpMethod: HTTPMethod, response: ResponseProtocol? = nil) {
        self.baseURL = baseURL
        self.path = path
        self.httpMethod = httpMethod
        self.response = response
        self.routeComponents = Route.Component.components(of: self.path.rawValue)
    }
    
    func fulfill(_ pathComponents: [String]) -> Bool {
        var remainingRouteComponents = self.routeComponents
        
        for (index, component) in pathComponents.enumerated() {
            guard
                self.routeComponents.count >= index + 1
                else { return false }
            remainingRouteComponents.remove(at: 0)
            
            switch self.routeComponents[index] {
            case .path(let name) where name != component:
                return false
            default: break
            }
        }
        
        return remainingRouteComponents.isEmpty
    }
}

extension Route: Equatable {
    public static func == (lhs: Route, rhs: Route) -> Bool {
        let test = lhs.path == rhs.path && lhs.baseURL == rhs.baseURL && lhs.httpMethod == rhs.httpMethod
        
        if let lhsResponse = lhs.response, let rhsResponse = rhs.response {
            return test && lhsResponse.statusCode == rhsResponse.statusCode &&
            lhsResponse.contentData == rhsResponse.contentData &&
            lhsResponse.headerFields == rhsResponse.headerFields
        }
        
        return test
    }
}

extension Route: CustomDebugStringConvertible {
    public var debugDescription: String {
        return """
        Route => [
        Base URL - \(self.baseURL)
        Path - \(self.path.rawValue)
        HTTP Method - \(self.httpMethod.rawValue.uppercased())
        ]
        """
    }
}

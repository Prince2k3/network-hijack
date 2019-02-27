import Foundation

public protocol Redirect {
    var routes: [Route] { get set }
    
    mutating func addRoute(_ route: Route)
    
    func route(for path: Route.Path) -> Route?
    func route(for urlRequest: URLRequest) -> Route?
}

extension Redirect {
    public mutating func addRoute(_ route: Route) {
        if !self.routes.contains(route) {
            self.routes.append(route)
            debugPrint(route)
        }
    }
    
    public func route(for path: Route.Path) -> Route? {
        return self.routes.first { $0.path == path }
    }
    
    public func route(for urlRequest: URLRequest) -> Route? {
        guard
            let url = urlRequest.url,
            let httpMethod = urlRequest.httpMethod,
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            else { return nil }
        
        return self.routes.first { route in
            guard
                route.fulfill(components.path.pathComponents),
                httpMethod.lowercased() == route.httpMethod.rawValue.lowercased()
                else { return false }
            
            return true
        }
    }
}

public struct InMemoryRedirect: Redirect {
    public var routes: [Route] = []
}

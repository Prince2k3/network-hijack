import Foundation

public class Redirect {
    public typealias ObservableHandler = ((Response?, URLRequest) -> Response?)
    public var observables: [Route.Path: ObservableHandler] = [:]
    
    private(set) var routes: [Route]  = []
    
    public func response(for urlRequest: URLRequest) -> Response? {
        guard
            let route = self.route(for: urlRequest)
            else { return nil }
        
        if let handler = observables[route.path] {
            return handler(route.builder(urlRequest), urlRequest)
        }
        
        return route.builder(urlRequest)
    }
    
    public func addRoute(_ route: Route) {
        guard
            !routes.contains(route)
            else { return }
        routes.append(route)
        debugPrint(route)
    }
    
    public func addRoutes(_ routes: [Route]) {
        routes.forEach { addRoute($0) }
    }
    
    public func route(for path: Route.Path) -> Route? {
        return routes.first { $0.path == path }
    }
    
    public func route(for urlRequest: URLRequest) -> Route? {
        guard
            let url = urlRequest.url,
            let httpMethod = urlRequest.httpMethod,
            let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
            else { return nil }
        
        return routes.first { route in
            guard
                route.fulfill(urlComponents.path.pathComponents),
                httpMethod.lowercased() == route.httpMethod.rawValue.lowercased()
                else { return false }
            
            return true
        }
    }
    
    public func clearRoutes() {
        self.routes = []
    }
    
    public func observe(_ path: Route.Path, handler: @escaping ObservableHandler) {
        observables[path] = handler
    }
}

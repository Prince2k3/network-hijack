import Foundation

public class Context {
    public typealias ContextObservableHandler = ((ResponseProtocol?, URLRequest) -> ResponseProtocol?)
    
    private(set) var redirect: Redirect
    
    public init(redirect: Redirect) {
        self.redirect = redirect
    }
    
    public func response(for urlRequest: URLRequest) -> ResponseProtocol? {
        guard
            let route = self.redirect.route(for: urlRequest)
            else { return nil }
        
        if let handler = self.observables[route.path] {
            return handler(route.response, urlRequest)
        }
        
        return route.response
    }
    
    public func addRoute(_ route: Route) {
        self.redirect.addRoute(route)
    }
    
    public func addRoutes(_ routes: [Route]) {
        routes.forEach { addRoute($0) }
    }
    
    public func route(for path: Route.Path) -> Route? {
        return self.redirect.route(for: path)
    }
    
    public func clearRoutes() {
        self.redirect.routes = []
    }
    
    public var observables: [Route.Path: ContextObservableHandler] = [:]
    
    public func observe(_ path: Route.Path, handler: @escaping ContextObservableHandler) {
        self.observables[path] = handler
    }
}

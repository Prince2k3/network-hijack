import Foundation

public protocol Routable {
    static var routes: [Route] { get }
}

public typealias ResponseBuilder = (URLRequest) -> (Response)

public struct Route: Equatable {
    let id: UUID
    
    public let path: Route.Path
    public let delay: TimeInterval?
    public let builder: ResponseBuilder
    
    private var pathComponents: [Route.Component]
    
    init(path: Route.Path, delay: TimeInterval? = nil, response builder: @escaping ResponseBuilder) {
        self.path = path
        self.delay = delay
        self.builder = builder
        self.id = UUID()
        
        self.pathComponents = Route.makePathComponents(from: path)
    }
    
    func fulfill(_ pathComponents: [String]) -> Bool {
        var remainingRouteComponents = pathComponents
        
        for (index, component) in pathComponents.enumerated() {
            guard
                pathComponents.count >= index + 1
                else { return false }
            remainingRouteComponents.remove(at: 0)
            
            switch self.pathComponents[index] {
            case let .path(name) where name != component:
                return false
            default: break
            }
        }
        
        return remainingRouteComponents.isEmpty
    }
}

extension Route {
    public var httpMethod: HTTPMethod {
        return path.httpMethod
    }
}

public func == (lhs: Route, rhs: Route) -> Bool {
    return lhs.id == rhs.id
}

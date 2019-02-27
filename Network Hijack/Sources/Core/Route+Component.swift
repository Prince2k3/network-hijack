import Foundation

extension Route {
    enum Component {
        case path(String)
        case placeholder(String)
    }
}

extension Route.Component: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case let .path(name):
            return name
        case let .placeholder(name):
            return name
        }
    }
}

extension Route.Component {
    static func components(of route: String) -> [Route.Component] {
        let pathComponents = route.pathComponents
        var components = [Route.Component]()
        
        for component in pathComponents {
            
            // check if this is a placeholder
            if component.first == ":" {
                let parameterName = String(component.dropFirst())
                components.append(.placeholder(parameterName))
                continue
            }
            
            // normal path component
            components.append(.path(component))
        }
        
        return components
    }
}

extension Route.Component: Equatable {
    static func == (lhs: Route.Component, rhs: Route.Component) -> Bool {
        switch lhs {
        case .path(let lhsName):
            guard case .path(let rhsName) = rhs else { return false }
            return (lhsName == rhsName)
        case .placeholder(let lhsName):
            guard case .placeholder(let rhsName) = rhs else { return false }
            return (lhsName == rhsName)
        }
    }
}

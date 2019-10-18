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

extension Route.Component: Equatable {
    static func == (lhs: Route.Component, rhs: Route.Component) -> Bool {
        switch (lhs, rhs) {
        case let (.path(lhsName), .path(rhsName)):
            return (lhsName == rhsName)
        case let (.placeholder(lhsName), .placeholder(rhsName)):
            return (lhsName == rhsName)
        default:
            return false
        }
    }
}

extension Route {
    static func makePathComponents(from routePath: Route.Path) -> [Route.Component] {
        let pathComponents = routePath.value.pathComponents
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

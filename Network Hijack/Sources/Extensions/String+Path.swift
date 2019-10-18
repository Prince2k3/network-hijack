import Foundation

extension String {
    var pathComponents: [String] {
        var path = self
        
        if path.first == "/" {
            path = String(path.dropFirst())
        }
        
        if path.last == "/" {
            path = String(path.dropLast())
        }
        
        return path.components(separatedBy: "/")
    }
}

import Foundation

public protocol ResponseProtocol {
    var statusCode: Int { get set }
    var contentData: Data { get set }
    var headerFields: [String: String] { get }
}

public struct Response: ResponseProtocol {
    public var headerFields: [String: String]
    public var statusCode: Int
    public var contentData: Data
    
    public init(statusCode: Int = 200, headerFields: [String: String] = ["Content-Type": "application/json"], contentData: Data = Data()) {
        self.headerFields = headerFields
        self.contentData = contentData
        
        if contentData.isEmpty {
            self.statusCode = 204
        } else {
            self.statusCode = statusCode
        }
    }
}

extension Response: Equatable {
    public static func == (lhs: Response, rhs: Response) -> Bool {
        return lhs.statusCode == rhs.statusCode &&
               lhs.contentData == rhs.contentData
    }
}

extension Response {
    public init(statusCode: Int = 200, filePath: String) throws {
        self.init(statusCode: statusCode)
        let url = URL(fileURLWithPath: filePath)
        let data = try Data(contentsOf: url)
        self.contentData = data
    }
    
    public init(statusCode: Int = 200, contentData: Data) throws {
        self.init(statusCode: statusCode)
        self.contentData = contentData
    }
    
    public init(statusCode: Int = 200, object: Any) throws {
        self.init(statusCode: statusCode)
        self.contentData = try JSONSerialization.data(withJSONObject: object, options: [])
    }
}

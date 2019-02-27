import Foundation

public protocol ResponseProtocol {
    var statusCode: Int { get set }
    var contentData: Data { get set }
    var headerFields: [String: String] { get }
}

public struct Response: ResponseProtocol {
    public var headerFields: [String: String] = ["Content-Type": "application/json"]
    public var statusCode: Int
    public var contentData: Data = Data()
    
    public init(statusCode: Int = 200, headerFields: [String: String]? = nil) {
        self.statusCode = statusCode
        self.headerFields = headerFields ?? self.headerFields
    }
    
    public mutating func setContentData(using filePath: String) throws {
        let url = URL(fileURLWithPath: filePath)
        let data = try Data(contentsOf: url)
        self.contentData = data
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
        self.init(statusCode: statusCode, headerFields: nil)
        try setContentData(using: filePath)
    }
    
    public init(statusCode: Int = 200, contentData: Data = Data()) throws {
        self.init(statusCode: statusCode, headerFields: nil)
        self.contentData = contentData
    }
    
    public init(statusCode: Int = 200, object: Any) throws {
        self.init(statusCode: statusCode, headerFields: nil)
        self.contentData = try JSONSerialization.data(withJSONObject: object, options: [])
    }
}

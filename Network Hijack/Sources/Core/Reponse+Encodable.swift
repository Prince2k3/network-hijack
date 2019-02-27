import Foundation

public struct EncodableResponse<T: Encodable>: ResponseProtocol {
    public let headerFields: [String: String]
    public var statusCode: Int
    public var contentData: Data
    
    public init(statusCode: Int, headerFields: [String: String] = ["Content-Type": "application/json"]) {
        self.statusCode = statusCode
        self.headerFields = headerFields
        self.contentData = Data()
    }
}

extension EncodableResponse: Equatable {
    public static func == (lhs: EncodableResponse, rhs: EncodableResponse) -> Bool {
        return lhs.statusCode == rhs.statusCode &&
            lhs.contentData == rhs.contentData
        
    }
}

extension EncodableResponse {
    public init(statusCode: Int = 200, model: T, encoder: JSONEncoder = .init()) throws {
        self.init(statusCode: statusCode)
        self.contentData = try encoder.encode(model)
    }
}

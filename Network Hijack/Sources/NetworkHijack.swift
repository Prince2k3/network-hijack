import Foundation

public final class NetworkHijack: URLProtocol {
    private var isCancelled: Bool = false
    
    public static var `default`: Context = {
        .init(redirect: InMemoryRedirect())
    }()
    
    static var redirectAllRequests: Bool = true
    
    public override class func canInit(with request: URLRequest) -> Bool {
        guard !self.redirectAllRequests else { return true }
        return self.default.response(for: request) != nil
    }
    
    public override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    public override func startLoading() {
        self.isCancelled = false
        
        if let response = NetworkHijack.default.response(for: self.request) {
            involkeResponse(toRequest: self.request, response: response)
        } else {
            self.client?.urlProtocol(self, didFailWithError: NetworkHijack.Error.noResponseFound)
        }
    }
    
    public override func stopLoading() {
        self.isCancelled = true
    }
    
    public func involkeResponse(toRequest request: URLRequest, response: ResponseProtocol) {
        guard
            let url = request.url,
            let urlResponse = HTTPURLResponse(url: url, statusCode: response.statusCode, httpVersion: "", headerFields: response.headerFields),
            !self.isCancelled
            else { return }
        
        self.client?.urlProtocol(self, didReceive: urlResponse, cacheStoragePolicy: .allowedInMemoryOnly)
        if !response.contentData.isEmpty {
            self.client?.urlProtocol(self, didLoad: response.contentData)
        }
        self.client?.urlProtocolDidFinishLoading(self)
    }
}

// Conveinence

extension NetworkHijack {
    public static func enable(sessionConfiguration: URLSessionConfiguration) {
        var protocolClasses = sessionConfiguration.protocolClasses ?? []
        protocolClasses.insert(self, at: 0)
        sessionConfiguration.protocolClasses = protocolClasses
    }
    
    public static func disable(sessionConfiguration: URLSessionConfiguration) {
        guard var protocolClasses = sessionConfiguration.protocolClasses else { return }
        
        for (index, protocolClass) in protocolClasses.enumerated() where protocolClass == self {
            protocolClasses.remove(at: index)
        }
    }
    
    public static func clearRoutes() {
        self.default.clearRoutes()
    }
    
    public static func load<T: Routable>(_ routable: T.Type) {
        self.default.addRoutes(routable.routes)
    }
}

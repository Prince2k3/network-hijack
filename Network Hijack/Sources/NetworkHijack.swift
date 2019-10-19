import Foundation

public final class NetworkHijack: URLProtocol {
    private var enableDownloading: Bool = true
    private let operationQueue: OperationQueue = OperationQueue()
    
    static let redirect: Redirect = .init()

    public override static func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    public override static func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    public override func startLoading() {
        if let response = NetworkHijack.redirect.response(for: request) {
            involkeResponse(response)
        } else {
            client?.urlProtocol(self, didFailWithError: NetworkHijack.Error.noResponseFound)
        }
    }
    
    public override func stopLoading() {
        enableDownloading = false
        operationQueue.cancelAllOperations()
    }
    
    public func involkeResponse(_ response: Response) {
        switch response {
        case let .failure(error):
            client?.urlProtocol(self, didFailWithError: error)
        case .success(var response, let download):
            let headers = self.request.allHTTPHeaderFields
            
            switch(download) {
            case var .content(data):
                applyRangeFromHTTPHeaders(headers, toData: &data, andUpdateResponse: &response)
                client?.urlProtocol(self, didLoad: data)
                client?.urlProtocolDidFinishLoading(self)
            case .streamContent(data: var data, inChunksOf: let bytes):
                applyRangeFromHTTPHeaders(headers, toData: &data, andUpdateResponse: &response)
                self.download(data, inChunksOfBytes: bytes)
            case .noContent:
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                client?.urlProtocolDidFinishLoading(self)
            }
        }
    }
    
    private func download(_ data: Data?, inChunksOfBytes bytes: Int) {
        guard
            let data = data
            else { client?.urlProtocolDidFinishLoading(self) ; return }
        
        self.operationQueue.maxConcurrentOperationCount = 1
        self.operationQueue.addOperation {
            self.download(data, fromOffset: 0, withMaxLength: bytes)
        }
    }
    
    private func download(_ data: Data, fromOffset offset: Int, withMaxLength maxLength: Int) {
        guard
            let queue = OperationQueue.current
            else { return }
        
        guard
            offset < data.count
            else { client?.urlProtocolDidFinishLoading(self) ; return }
        
        let length = min(data.count - offset, maxLength)
        
        queue.addOperation { 
            guard
                self.enableDownloading
                else { self.enableDownloading = true ; return }
            
            let subdata = data.subdata(in: offset ..< (offset + length))
            self.client?.urlProtocol(self, didLoad: subdata)
            Thread.sleep(forTimeInterval: 0.01)
            self.download(data, fromOffset: offset + length, withMaxLength: maxLength)
        }
    }
    
    private func extractRangeFromHTTPHeaders(_ headers: [String : String]?) -> Range<Int>? {
        guard
            let rangeStr = headers?["Range"]
            else { return nil }
        
        let range = rangeStr.components(separatedBy: "=")[1]
                            .components(separatedBy: "-")
                            .compactMap { Int($0) }
        let loc = range[0]
        let length = range[1] + 1
        return loc..<length
    }
    
    private func applyRangeFromHTTPHeaders(_ headers: [String : String]?, toData data: inout Data, andUpdateResponse response: inout URLResponse) {
        
        guard
            let range = extractRangeFromHTTPHeaders(headers)
            else { client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed) ; return }
        
        
        let fullLength = data.count
        data = data.subdata(in: range)
        
        //Attach new headers to response
        if let r = response as? HTTPURLResponse {
            var header = r.allHeaderFields as! [String:String]
            header["Content-Length"] = String(data.count)
            header["Content-Range"] = "bytes \(range.lowerBound)-\(range.upperBound)/\(fullLength)"
            response = HTTPURLResponse(url: r.url!, statusCode: r.statusCode, httpVersion: nil, headerFields: header)!
        }
        
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
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
}

// Redirect exposed

extension NetworkHijack {
    public static func addRoute(_ route: Route) {
        redirect.addRoute(route)
    }
    
    public static func addRoutes(_ routes: [Route]) {
        redirect.addRoutes(routes)
    }
    
    public static func clearRoutes() {
        redirect.clearRoutes()
    }
    
    public static func observe(_ path: Route.Path, handler: @escaping Redirect.ObservableHandler) {
        redirect.observe(path, handler: handler)
    }
}

// Routable

extension NetworkHijack {
    public static func load<T: Routable>(_ routable: T.Type) {
        redirect.addRoutes(routable.routes)
    }
}

//

public func route(path: Route.Path, delay: TimeInterval? = nil, response builder: @escaping ResponseBuilder) {
    let route = Route(path: path, delay: delay, response: builder)
    NetworkHijack.addRoute(route)
}

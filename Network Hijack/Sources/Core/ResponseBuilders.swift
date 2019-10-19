import Foundation

public func failure(_ error: Error? = nil, message: String = "") -> (_ request: URLRequest) -> Response {
    return { _ in
        return .failure(NetworkHijack.Error(error: error, message: message))
    }
}

public func http(_ status: Int = 200, headers: [String: String]? = nil, download: Download = nil) -> (_ request: URLRequest) -> Response {
    return { (request: URLRequest) in
        if let response = HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: nil, headerFields: headers) {
            return Response.success(response, download)
        }
        
        return failure(message: "Failed to make response")(request)
    }
}

public func json(_ body: Any, status: Int = 200, headers: [String: String]? = nil) -> (_ request: URLRequest) -> Response {
    return { (request: URLRequest) in
        do {
            let data = try JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions())
            return jsonData(data, status: status, headers: headers)(request)
        }
        catch { return failure(error, message: error.localizedDescription)(request) }
    }
}

public func json<T: Encodable>(_ body: T, status: Int = 200, headers: [String: String]? = nil, encoder: JSONEncoder = .init()) -> (_ request: URLRequest) -> Response {
    return { (request: URLRequest) in
        do {
            let data = try encoder.encode(body)
            return jsonData(data, status: status, headers: headers)(request)
        }
        catch { return failure(error, message: error.localizedDescription)(request) }
    }
}

public func json(filename: String, status: Int = 200, headers: [String: String]? = nil, bundle: Bundle = .main) -> (_ request: URLRequest) -> Response {
    return { (request: URLRequest) in
        do {
            guard
                let path = bundle.path(forResource: filename, ofType: nil)
                else { return .failure(NetworkHijack.Error(message: "JSON file not found")) }
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            return jsonData(data, status: status, headers: headers)(request)
        }
        catch { return failure(error, message: error.localizedDescription)(request) }
    }
}

public func jsonData(_ data: Data, status: Int = 200, headers: [String: String]? = nil) -> (_ request: URLRequest) -> Response {
    return { (request: URLRequest) in
        var headers = headers ?? [String: String]()
        if headers["Content-Type"] == nil {
            headers["Content-Type"] = "application/json; charset=utf-8"
        }
        
        return http(status, headers: headers, download: .content(data))(request)
    }
}
